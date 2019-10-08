


test_that("funder searching works", {
  skip_on_cran()
  search1 <- tsg_search_grants(search = c("bbc", "caBinet"))

  # expect_length(search1, 13)
  expect_true("BBC Children in Need grants" %in% search1$title)

  search2 <- tsg_search_grants(
    search = "Esmee",
    search_in = "publisher_website"
  )

  # expect_length(search2, 13)
  expect_true(grepl("Esmée", search2$title))
})
