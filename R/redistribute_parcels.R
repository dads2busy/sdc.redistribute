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
#' @details
#' Each source value is split across the points inside that source polygon in
#' proportion to `weights` (equally when `weights = NULL`), then summed within
#' each target polygon. A source polygon that contains no points contributes
#' nothing to any target (its value cannot be placed). If the total weight of a
#' source's points is zero, that source likewise contributes nothing.
#' If `target` already has a column named like a redistributed measure, it is
#' overwritten; pass `suffix` to keep both.
#' @examples
#' src <- sf::st_sf(pop = 100, geometry = sf::st_sfc(
#'   sf::st_polygon(list(rbind(c(0,0), c(2,0), c(2,2), c(0,2), c(0,0)))),
#'   crs = 3857))
#' tgt <- sf::st_sf(id = c("A", "B"), geometry = sf::st_sfc(
#'   sf::st_polygon(list(rbind(c(0,0), c(1,0), c(1,2), c(0,2), c(0,0)))),
#'   sf::st_polygon(list(rbind(c(1,0), c(2,0), c(2,2), c(1,2), c(1,0)))),
#'   crs = 3857))
#' pts <- sf::st_sf(geometry = sf::st_sfc(
#'   sf::st_point(c(0.5, 1)), sf::st_point(c(1.5, 1)), crs = 3857))
#' redistribute_parcels(src, tgt, pts, extensive = "pop")
#' @export
redistribute_parcels <- function(source, target, points, extensive = NULL,
                                 weights = NULL, suffix = NULL) {
  if (is.null(extensive)) {
    stop("Supply at least one column in `extensive`.", call. = FALSE)
  }
  .validate_layers(source, target, extensive)
  if (!.is_sf(points)) stop("`points` must be an sf object.", call. = FALSE)
  if (!is.null(weights) && !weights %in% names(points)) {
    stop(sprintf("`weights` column '%s' not found in `points`.", weights),
         call. = FALSE)
  }
  reserved <- c(".src_id", ".tgt_id", ".w", ".wsum")
  if (any(reserved %in% names(source)) || any(reserved %in% names(target)) ||
      any(reserved %in% names(points))) {
    stop("`source`/`target`/`points` must not contain reserved column names: ",
         paste(reserved, collapse = ", "), call. = FALSE)
  }
  if (is.na(sf::st_crs(source)$wkt)) {
    stop("`source` has no CRS; set one with sf::st_crs() before redistributing.",
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
    share <- d[[".w"]] / d[[".wsum"]]
    share[!is.finite(share)] <- 0
    piece <- d[[col]] * share
    agg <- tapply(piece, d[[".tgt_id"]], sum, na.rm = TRUE)
    vals <- rep(0, nrow(target))
    vals[as.integer(names(agg))] <- as.numeric(agg)
    out[[.suffixed(col, suffix)]] <- vals
  }

  out[[".tgt_id"]] <- NULL
  out
}
