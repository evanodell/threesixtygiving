

test_that("funder searching works", {
  skip_on_cran()
  search1 <- tsg_search_funders(search = c("bbc", "caBinet"))

  # expect_length(search1, 13)
  expect_true("BBC Children in Need grants" %in% search1$title)

  search2 <- tsg_search_funders(
    search = c("citybridgetrust", "esmEE"),
    search_in = "publisher_website"
  )

  # expect_length(search2, 13)
  expect_true(any(grepl("City Bridge", search2$publisher_name)))

  search2 <- tsg_specific_df(search1)

  expect_true(tibble::is_tibble(search2[[1]]))
  expect_equal(length(search2), nrow(search1))

  expect_error(tsg_specific_df("search1"))
})
