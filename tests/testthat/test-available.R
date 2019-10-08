test_that("retrieve available data works", {
  skip_on_cran()
  available_df <- tsg_available()

  expect_true(tibble::is_tibble(available_df))
})
