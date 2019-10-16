
#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @details Due to the structure of the 360 Giving data, the package will make
#' multiple attempts to request data. This can cause issues with servers
#' automatically blocking requests, you can use [tsg_missing()] to identify
#' missing sets of grant data.
#'
#' @param verbose If `TRUE`, prints console messages.
#' @param timeout The maximum request time, in seconds. If data is not returned
#' in this time, a value of `NA` is returned for that dataset.
#' @param retries The number of retries to make if a request is not successful.
#' Defaults to 3.
#'
#' @return A list of tibbles with grant data.
#' @export
#'
#' @examples
#' \donttest{
#' all_grants <- tsg_all_grants()
#' }

tsg_all_grants <- function(verbose = TRUE, timeout = 30, retries = 3) {
  grant_df <- tsg_available()

  df <- tsg_data_retrieval(grant_df, verbose = verbose, timeout = timeout,
                           retries = retries)

  df
}
