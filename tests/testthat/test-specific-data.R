test_that("retrieving specific datsets works", {

  specific1 <- tsg_specific_data(search = c("bbc", "caBinet"))

  expect_type(specific1, "list")
  expect_true(tibble::is_tibble(specific1[[1]]))

})
