


#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @param with_meta If `TRUE`
#' @param verbose If `TRUE`, prints console messages.
#'
#' @return A list of data frames.
#' @export
#'
#' @examples \donttest{
#' all_grants <- tsg_all_grants()
#' }
tsg_all_grants <- function(with_meta = TRUE, verbose = TRUE) {
  grant_df <- tsg_available()

  df <- tsg_data_retrieval(grant_df, verbose = verbose)

   if (with_meta) {
  #   df2 <- tibble::tibble(grant_df, df)
   }
  df
}
