


test_that("retrieve specific datasets", {
  spec1 <- tsg_specific_data(search = c("bbc", "cabinet"))

  expect_type(spec1, "list")
  expect_type(tibble::is_tibble(spec1[[1]]))

})
