#' Area-weighted redistribution between polygon layers
#'
#' @param source An `sf` polygon layer carrying the values to redistribute.
#' @param target An `sf` polygon layer to estimate values for.
#' @param extensive Character vector of count column names in `source` to
#'   redistribute as totals (area-share weighted, optionally rescaled to
#'   preserve the source total).
#' @param intensive Character vector of rate/density column names in `source`
#'   to redistribute as area-weighted means.
#' @param preserve_totals Logical; if `TRUE` (default) extensive results are
#'   rescaled so each target column sums to the source total.
#' @param suffix Optional string appended to each new column name.
#' @return The `target` layer (an `sf` object) with one new column per
#'   redistributed measure.
#' @export
redistribute_direct <- function(source, target, extensive = NULL,
                                intensive = NULL, preserve_totals = TRUE,
                                suffix = NULL) {
  .validate_layers(source, target, c(extensive, intensive))
  .require_projected(source, "source")
  target <- .align_crs(target, source)

  source[[".src_area"]] <- as.numeric(sf::st_area(source))
  target[[".tgt_id"]] <- seq_len(nrow(target))
  target[[".tgt_area"]] <- as.numeric(sf::st_area(target))

  src_cols <- c(".src_area", extensive, intensive)
  ints <- suppressWarnings(sf::st_intersection(
    source[, src_cols], target[, c(".tgt_id", ".tgt_area")]
  ))
  keep <- !is.na(sf::st_dimension(ints)) & sf::st_dimension(ints) == 2L
  ints <- ints[keep, ]
  ints[[".int_area"]] <- as.numeric(sf::st_area(ints))
  d <- sf::st_drop_geometry(ints)

  out <- target

  for (col in extensive) {
    piece <- d[[col]] * (d[[".int_area"]] / d[[".src_area"]])
    agg <- tapply(piece, d[[".tgt_id"]], sum, na.rm = TRUE)
    vals <- rep(0, nrow(target))
    vals[as.integer(names(agg))] <- as.numeric(agg)
    if (isTRUE(preserve_totals)) {
      src_total <- sum(source[[col]], na.rm = TRUE)
      tgt_total <- sum(vals)
      if (tgt_total > 0 && src_total > 0) vals <- vals * (src_total / tgt_total)
    }
    out[[.suffixed(col, suffix)]] <- vals
  }

  for (col in intensive) {
    piece <- d[[col]] * (d[[".int_area"]] / d[[".tgt_area"]])
    agg <- tapply(piece, d[[".tgt_id"]], sum, na.rm = TRUE)
    vals <- rep(NA_real_, nrow(target))
    vals[as.integer(names(agg))] <- as.numeric(agg)
    out[[.suffixed(col, suffix)]] <- vals
  }

  out[[".tgt_id"]] <- NULL
  out[[".tgt_area"]] <- NULL
  out
}
