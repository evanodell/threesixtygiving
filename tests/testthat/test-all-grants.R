
test_that("all grant retrieval works", {
  skip_on_cran()
  skip_on_appveyor()
  skip_on_ci()
  # skip("local-testing")

  ag1 <- tsg_all_grants(timeout = 10, retries = 1)
  expect_true(is.list(ag1))

  core <- tsg_core_data(ag1)
  expect_length(core, 13)
  expect_equal(class(core$award_date), "Date")
  expect_equal(class(core$amount_awarded), "numeric")
})
