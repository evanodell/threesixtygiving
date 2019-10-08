
#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @param core_data If `TRUE`
#' @param verbose If `TRUE`, prints console messages.
#'
#' @return A list of data frames.
#' @export
#'
#' @examples \donttest{
#' all_grants <- tsg_all_grants()
#' }


tsg_all_grants <- function(verbose = TRUE) {
  grant_df <- tsg_available()

  df <- threesixtygiving:::tsg_data_retrieval(grant_df, verbose = verbose)

  df
}
