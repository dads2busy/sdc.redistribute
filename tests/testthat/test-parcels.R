test_that("parcels spread a count evenly across contained points", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  pts <- pts_sf(rbind(c(0.5, 0.5), c(0.5, 1.5), c(0.5, 1.0), c(1.5, 1.0)))
  out <- redistribute_parcels(src, tgt, pts, extensive = "pop")
  expect_equal(out$pop[out$id == "A"], 75)
  expect_equal(out$pop[out$id == "B"], 25)
  expect_equal(sum(out$pop), 100)
})
