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
#' @details
#' Extensive measures (counts) are redistributed by each intersection's share of
#' the source polygon area and, when `preserve_totals = TRUE`, rescaled so the
#' target totals match the source totals. Intensive measures (rates/densities)
#' are area-weighted means: the sum of each source value times the intersection's
#' share of the target polygon area (the standard areal-weighting intensive
#' estimator). This equals a true area-weighted mean when the target is fully
#' covered by the source and treats any uncovered part of a target as
#' contributing zero. `NA` source values are omitted from the weighted sums.
#' @examples
#' src <- sf::st_sf(pop = 100, geometry = sf::st_sfc(
#'   sf::st_polygon(list(rbind(c(0,0), c(2,0), c(2,2), c(0,2), c(0,0)))),
#'   crs = 3857))
#' tgt <- sf::st_sf(id = c("A", "B"), geometry = sf::st_sfc(
#'   sf::st_polygon(list(rbind(c(0,0), c(1,0), c(1,2), c(0,2), c(0,0)))),
#'   sf::st_polygon(list(rbind(c(1,0), c(2,0), c(2,2), c(1,2), c(1,0)))),
#'   crs = 3857))
#' redistribute_direct(src, tgt, extensive = "pop")
#' @export
redistribute_direct <- function(source, target, extensive = NULL,
                                intensive = NULL, preserve_totals = TRUE,
                                suffix = NULL) {
  if (is.null(extensive) && is.null(intensive)) {
    stop("Supply at least one of `extensive` or `intensive`.", call. = FALSE)
  }
  .validate_layers(source, target, c(extensive, intensive))
  reserved <- c(".src_area", ".int_area", ".tgt_id", ".tgt_area")
  if (any(reserved %in% names(source)) || any(reserved %in% names(target))) {
    stop("`source`/`target` must not contain reserved column names: ",
         paste(reserved, collapse = ", "), call. = FALSE)
  }
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
