
#' Get specific datasets
#'
#' Retrieve data contained with all or specific rows of a tibble
#' returned by [tsg_available()] or [tsg_missing()].
#'
#' @param x All or a subset of a tibble returned by
#'  [tsg_available()] or [tsg_missing()]
#' @inheritParams tsg_all_grants
#'
#' @return A list of tibbles with grant data.
#' @export
#' @seealso [tsg_search_grants()]
#' @seealso [tsg_available()]
#' @seealso [tsg_missing()]
#'
#' @examples
#' \dontrun{
#' all_grants <- tsg_all_grants()
#'
#' missing_grants <- tsg_missing(all_grants)
#'
#' more_grants <- tsg_specific_df(missing_grants)
#' }
#'
tsg_specific_df <- function(x, verbose = TRUE, timeout = 30, retries = 0) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data frames with grant metadata.", call. = FALSE)
  }

  df <- tsg_data_retrieval(x,
    verbose = verbose, timeout = timeout,
    retries = retries
  )

  df
}
