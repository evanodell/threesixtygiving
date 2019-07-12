

#' Retrieve specific datasets
#'
#'
#' Returns a list of tibble with details of all grants from funders
#' where funder data matches one or more search strings. If only one dataset
#' matches queries, returns a tibble of that dataset.
#'
#' @inheritParams tsg_search_grants
#'
#' @return A tibble or a list of tibbles.
#' @export
#'
#' @examples \donttest{
#'
#' }


tsg_specific_data <- function(search, search_in = NULL, verbose = TRUE,
                              ignore_case = TRUE, perl = FALSE, fixed = FALSE) {

  q_df <- tsg_search_grants(search = search, search_in = search_in,
                                verbose = verbose, ignore_case = ignore_case,
                                perl = perl, fixed = fixed)

  df <- tsg_data_retrieval(q_df, verbose = verbose)

  if (length(df == 1)) {
    df <- df[[1]]
  }

  df
}
