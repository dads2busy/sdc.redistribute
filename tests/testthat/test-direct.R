test_that("extensive count splits by area share and preserves the total", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  out <- redistribute_direct(src, tgt, extensive = "pop")
  expect_s3_class(out, "sf")
  expect_equal(out$pop, c(50, 50))
  expect_equal(sum(out$pop), sum(src$pop))
  expect_equal(out$id, c("A", "B"))  # target attributes retained
})

# Task 4 tests

test_that("intensive measure is an area-weighted mean", {
  src <- rbind(box_sf(0, 0, 1, 2, dens = 10), box_sf(1, 0, 2, 2, dens = 30))
  tgt <- box_sf(0, 0, 2, 2, id = "whole")
  out <- redistribute_direct(src, tgt, intensive = "dens")
  expect_equal(out$dens, 20)
})

test_that("suffix renames new columns and keeps source values out of target", {
  src <- box_sf(0, 0, 2, 2, pop = 80)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  out <- redistribute_direct(src, tgt, extensive = "pop", suffix = "_direct")
  expect_true("pop_direct" %in% names(out))
  expect_false("pop" %in% names(out))
})

test_that("identity: redistributing onto the same geometry is a no-op", {
  src <- rbind(box_sf(0, 0, 1, 1, pop = 5), box_sf(1, 0, 2, 1, pop = 7))
  out <- redistribute_direct(src, src, extensive = "pop")
  expect_equal(sort(round(out$pop, 6)), c(5, 7))
})

# Task 5 tests

test_that("redistribute_direct validates inputs", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- box_sf(0, 0, 1, 2)
  expect_error(redistribute_direct(src, tgt, extensive = "missing"),
               "not found in .source.")
  geo <- box_sf(0, 0, 2, 2, crs = 4326, pop = 100)
  expect_error(redistribute_direct(geo, tgt, extensive = "pop"),
               "geographic CRS")
})

test_that("redistribute_direct reprojects target to source CRS", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- sf::st_transform(
    rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B")), 4326)
  out <- redistribute_direct(src, tgt, extensive = "pop")
  expect_equal(sf::st_crs(out), sf::st_crs(src))
  expect_equal(round(sum(out$pop)), 100)
})
