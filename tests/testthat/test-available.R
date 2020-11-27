test_that("retrieve available data works", {
  skip_on_cran()

  available_df <- tsg_available()

  expect_true(tibble::is_tibble(available_df))

  avail_names <- c(
    "title", "description", "identifier", "license",
    "license_name", "issued", "modified", "download_url",
    "access_url", "data_type", "publisher_name",
    "publisher_website", "publisher_logo", "publisher_prefix"
  )

  expect_named(available_df, expected = avail_names)
  expect_true("json" %in% available_df$data_type)
  expect_true("Creative Commons Attribution 4.0 International (CC BY 4.0)"
              %in% available_df$license_name)
  expect_length(available_df, 14)


})
