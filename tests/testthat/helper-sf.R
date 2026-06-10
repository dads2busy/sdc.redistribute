box_sf <- function(xmin, ymin, xmax, ymax, crs = 3857, ...) {
  poly <- sf::st_polygon(list(rbind(
    c(xmin, ymin), c(xmax, ymin), c(xmax, ymax), c(xmin, ymax), c(xmin, ymin)
  )))
  if (is.na(crs)) {
    sf::st_sf(..., geometry = sf::st_sfc(poly))
  } else {
    sf::st_sf(..., geometry = sf::st_sfc(poly, crs = crs))
  }
}
