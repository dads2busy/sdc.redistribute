# Generates `sdc_example`: a tiny synthetic set of sf layers for examples and
# vignettes. Run with: source("data-raw/example_geographies.R")
make_box <- function(xmin, ymin, xmax, ymax) {
  sf::st_polygon(list(rbind(
    c(xmin, ymin), c(xmax, ymin), c(xmax, ymax), c(xmin, ymax), c(xmin, ymin))))
}

source_geo <- sf::st_sf(
  tract = c("T1", "T2"),
  pop = c(120, 80),
  geometry = sf::st_sfc(make_box(0, 0, 2, 2), make_box(2, 0, 4, 2), crs = 3857))

target_geo <- sf::st_sf(
  nbhd = c("N1", "N2", "N3"),
  geometry = sf::st_sfc(
    make_box(0, 0, 1.5, 2), make_box(1.5, 0, 2.5, 2), make_box(2.5, 0, 4, 2),
    crs = 3857))

set.seed(1)
pc <- expand.grid(x = seq(0.25, 3.75, by = 0.5), y = seq(0.25, 1.75, by = 0.5))
parcels <- sf::st_sf(
  units = sample(1:4, nrow(pc), replace = TRUE),
  geometry = sf::st_sfc(lapply(seq_len(nrow(pc)),
    function(i) sf::st_point(c(pc$x[i], pc$y[i]))), crs = 3857))

sdc_example <- list(source = source_geo, target = target_geo, parcels = parcels)

usethis::use_data(sdc_example, overwrite = TRUE)
