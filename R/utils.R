# Internal helpers. Not exported.

.is_sf <- function(x) inherits(x, "sf")

.validate_layers <- function(source, target, cols = character()) {
  if (!.is_sf(source)) stop("`source` must be an sf object.", call. = FALSE)
  if (!.is_sf(target)) stop("`target` must be an sf object.", call. = FALSE)
  missing <- setdiff(cols, names(source))
  if (length(missing) > 0) {
    stop(sprintf("Column(s) not found in `source`: %s",
                 paste(missing, collapse = ", ")), call. = FALSE)
  }
  invisible(TRUE)
}

.require_projected <- function(x, name) {
  crs <- sf::st_crs(x)
  if (is.na(crs)) {
    stop(sprintf("`%s` has no CRS; set one with sf::st_crs() before redistributing.", name),
         call. = FALSE)
  }
  if (isTRUE(sf::st_is_longlat(x))) {
    stop(sprintf(paste0("`%s` uses a geographic CRS; project to a planar CRS ",
                        "(e.g. sf::st_transform()) before redistributing."), name),
         call. = FALSE)
  }
  invisible(x)
}

.align_crs <- function(x, ref) {
  if (sf::st_crs(x) != sf::st_crs(ref)) {
    x <- sf::st_transform(x, sf::st_crs(ref))
  }
  x
}

.suffixed <- function(col, suffix) {
  if (is.null(suffix)) col else paste0(col, suffix)
}
