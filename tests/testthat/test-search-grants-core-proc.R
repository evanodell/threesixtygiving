test_that("grant_search works", {
  skip_on_cran()

  spec1 <- tsg_search_grants(search = c("bbc", "caBinet"))
  expect_true(is.list(spec1))

  proc_df <- tsg_process_data(spec1)
  expect_true(tibble::is_tibble(proc_df))
  expect_gte(nrow(proc_df), 1)

  spec2 <- tsg_search_grants("ear",
    search_in = "publisher_name",
    timeout = 10, retries = 1
  )

  core_df <- tsg_core_data(spec2)
  expect_true(tibble::is_tibble(core_df))
  expect_length(core_df, 11)
  expect_gte(nrow(core_df), 1)
})
