test_that("grant search and processing", {
  skip_on_cran()

  # Grant searching
  spec1 <- tsg_search_grants(search = c("bbc", "caBinet"))
  expect_type(spec1, "list")
  expect_true(tibble::is_tibble(spec1[[1]]))

  # Data process testing
  proc_df <- tsg_process_data(spec1)
  expect_true(tibble::is_tibble(proc_df))
  expect_gte(nrow(proc_df), 1)
  expect_equal(class(proc_df$award_date), "Date")
  expect_equal(class(proc_df$amount_awarded), "numeric")


  spec2 <- tsg_search_grants("ear",
    search_in = "publisher_name",
    timeout = 10, retries = 1
  )

  core_df <- tsg_core_data(spec2)
  expect_true(tibble::is_tibble(core_df))
  expect_length(core_df, 12)
  expect_gte(nrow(core_df), 1)

  spec3 <- tsg_search_grants(search = c("wolfson"))

  expect_true(is.numeric(spec3$amount_awarded))
})
