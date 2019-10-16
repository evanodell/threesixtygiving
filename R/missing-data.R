
#' Identify missing data sets
#'
#' Returns a tibble with details on any available data missing from a list
#' of grants returned by [tsg_all_grants()].
#'
#' @param x A list of tibble with grant data returned by [tsg_all_grants()].
#'
#' @return A tibble with details on funders missing data from a list of tibbles
#' passed to the function.
#' @export
#'
#' @examples \donttest{
#' all_grants <- tsg_all_grants()
#'
#' missing_grants <- tsg_missing(all_grants)
#' }

tsg_missing <- function(x) {
  if (!is.list(x)) {
    stop("`x` must be a list of data frames with grant data.", call. = FALSE)
  }

  avail_df <- tsg_available()

  x2 <- unique(unlist(purrr::map(x, "publisher_prefix")))

  missing_df <- dplyr::filter(avail_df, !("publisher_prefix" %in% x2))

  missing_df
}
