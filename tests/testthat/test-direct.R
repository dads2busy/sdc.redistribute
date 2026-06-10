test_that("extensive count splits by area share and preserves the total", {
  src <- box_sf(0, 0, 2, 2, pop = 100)
  tgt <- rbind(box_sf(0, 0, 1, 2, id = "A"), box_sf(1, 0, 2, 2, id = "B"))
  out <- redistribute_direct(src, tgt, extensive = "pop")
  expect_s3_class(out, "sf")
  expect_equal(out$pop, c(50, 50))
  expect_equal(sum(out$pop), sum(src$pop))
  expect_equal(out$id, c("A", "B"))  # target attributes retained
})
