

#' Search for specific datasets
#'
#' Returns a list of tibbles with details of all grants from specific funders.
#'
#' @details `tsg_search_grants` retrieves grants where funder data
#' matches one or more search strings. If only one dataset
#' matches queries, returns a tibble of that dataset.
#' Use [tsg_specific_df()] to pass a dataframe.
#'
#' @inheritParams tsg_search_funders
#' @param ... Additional params passed to [tsg_all_grants()]
#'
#' @return A single tibble (if only one grant maker matches the queries) or a
#' list of tibbles (if the query matches multiple datasets).
#' @export
#'
#' @seealso [tsg_search_funders()] for retrieving information on available
#' datasets from matching funders. [tsg_specific_df()] to retrieve data
#' contained with all or specific rows of a tibble returned
#' by [tsg_available()] or [tsg_missing()].
#'
#'
#' @examples
#' \dontrun{
#' specific1 <- tsg_search_grants(search = c("bbc", "caBinet"))
#' }
#'
tsg_search_grants <- function(search, search_in = NULL, verbose = TRUE,
                              ignore_case = TRUE, perl = FALSE,
                              fixed = FALSE, ...) {
  q_df <- tsg_search_funders(
    search = search, search_in = search_in,
    verbose = verbose, ignore_case = ignore_case,
    perl = perl, fixed = fixed
  )

  df <- tsg_data_retrieval(q_df, verbose = verbose, ...)

  if (length(df) == 1) {
    df <- df[[1]]
  }

  df
}
