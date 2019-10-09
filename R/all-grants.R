
#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @param verbose If `TRUE`, prints console messages.
#' @param timeout The maximum request time, in seconds. If data is not returned
#' in this time, a value of `NA` is returned for that dataset.
#'
#' @return A list of data frames.
#' @export
#'
#' @examples
#' \donttest{
#' all_grants <- tsg_all_grants()
#' }

tsg_all_grants <- function(verbose = TRUE, timeout = 30) {
  grant_df <- tsg_available()

  df <- tsg_data_retrieval(grant_df, verbose = verbose, timeout = timeout)

  df
}
