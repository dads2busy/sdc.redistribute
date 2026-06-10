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

test_that(".validate_layers rejects non-sf and missing columns", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- box_sf(0, 0, 1, 2)
  expect_error(.validate_layers(data.frame(), tgt, "pop"), "must be an sf")
  expect_error(.validate_layers(src, data.frame(), "pop"), "must be an sf")
  expect_error(.validate_layers(src, tgt, "nope"), "not found in .source.")
  expect_true(.validate_layers(src, tgt, "pop"))
})

test_that(".require_projected errors on geographic / missing CRS", {
  geo <- box_sf(0, 0, 1, 1, crs = 4326)
  expect_error(.require_projected(geo, "source"), "geographic CRS")
  nocrs <- box_sf(0, 0, 1, 1, crs = NA)
  expect_error(.require_projected(nocrs, "source"), "no CRS")
  proj <- box_sf(0, 0, 1, 1, crs = 3857)
  expect_silent(.require_projected(proj, "source"))
})

test_that(".align_crs transforms to the reference CRS", {
  ref <- box_sf(0, 0, 1, 1, crs = 3857)
  other <- box_sf(0, 0, 1, 1, crs = 4326)
  aligned <- .align_crs(other, ref)
  expect_equal(sf::st_crs(aligned), sf::st_crs(ref))
})
