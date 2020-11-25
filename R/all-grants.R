
#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @details Due to the structure of the 360 Giving data, the package will make
#' multiple attempts to request data. This can cause issues with servers
#' automatically blocking requests. You can use [tsg_missing()] to identify
#' missing sets of grant data.
#'
# @param data_dir Accepts a string and creates a folder in the current working
# directory with that string name and saves all files to it.
# Defaults to using `tempdir()`.
#' @param verbose If `TRUE`, prints console messages on data retrieval progress.
#' Defaults to `TRUE`.
#' @param timeout The maximum request time, in seconds. If data is not returned
#' in this time, a value of `NA` is returned for that dataset.
#' Defaults to 30 seconds.
#' @param retries The number of retries to make if a request is not successful.
#' Defaults to 0.
#' @param correct_names If `TRUE`, corrects known mistakes in column names,
#' such as spelling mistakes. Defaults to `TRUE`.
# @param skip_errors If `TRUE`, keeps processing additional files if one
# cannot be downloaded.
#'
#' @return A list of tibbles with grant data.
#' @export
#'
#' @examples
#' \dontrun{
#' all_grants <- tsg_all_grants()
#' }
#'
tsg_all_grants <- function(verbose = TRUE, timeout = 30, retries = 0,
                           correct_names = TRUE) {
  grant_df <- tsg_available()

  data_list <- tsg_data_retrieval(grant_df,
    verbose = verbose,
    timeout = timeout, retries = retries,
    correct_names = correct_names
  )
  data_list
}
