
test_that("all grant retrieval works", {
  skip_on_cran()
  skip_on_travis()

  ag1 <- tsg_all_grants()
  expect_true(is.list(ag1))
})
