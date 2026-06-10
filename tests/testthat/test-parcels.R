test_that("parcels spread a count evenly across contained points", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  pts <- pts_sf(rbind(c(0.5, 0.5), c(0.5, 1.5), c(0.5, 1.0), c(1.5, 1.0)))
  out <- redistribute_parcels(src, tgt, pts, extensive = "pop")
  expect_equal(out$pop[out$id == "A"], 75)
  expect_equal(out$pop[out$id == "B"], 25)
  expect_equal(sum(out$pop), 100)
})

test_that("weights split the value in proportion to a points column", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  pts <- pts_sf(rbind(c(0.5, 1.0), c(1.5, 1.0)), units = c(1, 3))
  out <- redistribute_parcels(src, tgt, pts, extensive = "pop", weights = "units")
  expect_equal(out$pop[out$id == "A"], 25)
  expect_equal(out$pop[out$id == "B"], 75)
})

test_that("redistribute_parcels validates inputs", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- box_sf(0, 0, 1, 2)
  pts <- pts_sf(rbind(c(0.5, 1.0)))
  expect_error(redistribute_parcels(src, tgt, data.frame(), extensive = "pop"),
               "`points` must be an sf")
  expect_error(redistribute_parcels(src, tgt, pts, extensive = "pop", weights = "nope"),
               "not found in .points.")
})

test_that("a source whose points all have zero weight contributes nothing (no NaN)", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  pts <- pts_sf(rbind(c(0.5, 1.0), c(1.5, 1.0)), units = c(0, 0))
  out <- redistribute_parcels(src, tgt, pts, extensive = "pop", weights = "units")
  expect_false(any(is.nan(out$pop)))
  expect_equal(out$pop, c(0, 0))
})
