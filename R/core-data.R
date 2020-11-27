
#' Core Data
#'
#' Given a list returned by [tsg_all_grants()] or [tsg_search_grants()], creates
#' a tibble with the core variables required by the
#' [360Giving](https://standard.threesixtygiving.org/en/latest/) open standard,
#' as well as the publisher prefix and dataset identifier,
#' which are useful for data processing, and the licence the data was
#'  published under.
#'
#' @param x A list of tibble with grant data returned by [tsg_all_grants()].
#' @inheritParams tsg_all_grants
#' @seealso [tsg_process_data()], which does the same processing but returns
#' all available variables.
#'
#' @return A tibble with the core variables in the 360Giving standard.
#' @export
#'
#' @examples
#' \dontrun{
#' grants <- tsg_all_grants()
#'
#' df <- tsg_core_data(grants)
#' }
tsg_core_data <- function(x, verbose = TRUE) {
  df <- tsg_core_process(x, verbose, process_type = "core")

  df
}
