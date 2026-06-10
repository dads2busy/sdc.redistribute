#' Dasymetric redistribution via a point layer
#'
#' Distributes each `source` value across the points (e.g. parcel centroids)
#' that fall inside it, then reaggregates the point-level values to `target`
#' polygons. With `weights = NULL` the value is split evenly across points;
#' otherwise it is split in proportion to a points column (the extension point
#' for household-size or unit-count weighting).
#'
#' @param source An `sf` polygon layer carrying the values to redistribute.
#' @param target An `sf` polygon layer to estimate values for.
#' @param points An `sf` point layer (e.g. parcel centroids).
#' @param extensive Character vector of count column names in `source`.
#' @param weights Optional name of a numeric column in `points` to weight by.
#' @param suffix Optional string appended to each new column name.
#' @return The `target` layer (an `sf` object) with one new column per measure.
#' @export
redistribute_parcels <- function(source, target, points, extensive = NULL,
                                 weights = NULL, suffix = NULL) {
  .validate_layers(source, target, extensive)
  if (!.is_sf(points)) stop("`points` must be an sf object.", call. = FALSE)
  if (!is.null(weights) && !weights %in% names(points)) {
    stop(sprintf("`weights` column '%s' not found in `points`.", weights),
         call. = FALSE)
  }
  points <- .align_crs(points, source)
  target <- .align_crs(target, source)

  source[[".src_id"]] <- seq_len(nrow(source))
  target[[".tgt_id"]] <- seq_len(nrow(target))

  pts <- sf::st_join(points, source[, ".src_id"], join = sf::st_within)
  pts <- pts[!is.na(pts[[".src_id"]]), ]
  pts <- sf::st_join(pts, target[, ".tgt_id"], join = sf::st_within)
  pts <- pts[!is.na(pts[[".tgt_id"]]), ]

  d <- sf::st_drop_geometry(pts)
  d[[".w"]] <- if (is.null(weights)) 1 else d[[weights]]
  wsum <- tapply(d[[".w"]], d[[".src_id"]], sum, na.rm = TRUE)
  d[[".wsum"]] <- as.numeric(wsum[as.character(d[[".src_id"]])])

  src_vals <- sf::st_drop_geometry(source)[, c(".src_id", extensive), drop = FALSE]
  d <- merge(d, src_vals, by = ".src_id")

  out <- target
  for (col in extensive) {
    piece <- d[[col]] * (d[[".w"]] / d[[".wsum"]])
    agg <- tapply(piece, d[[".tgt_id"]], sum, na.rm = TRUE)
    vals <- rep(0, nrow(target))
    vals[as.integer(names(agg))] <- as.numeric(agg)
    out[[.suffixed(col, suffix)]] <- vals
  }

  out[[".tgt_id"]] <- NULL
  out
}
