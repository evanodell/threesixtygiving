



#' Title
#'
#' Return all grants matching a particular search string.
#'
#' @param search The string to search for.
#' @param search_in The name of the column to search in.
#' @inheritParams tsg_all_grants
#'
#' @return
#' @export
#'
#' @examples
tsg_search_grants <- function(search, search_in = "publisher_name", verbose = TRUE) {
  grant_df <- tsg_available()

  query <- paste0(search, collapse = "|")

  columns <- paste(search_in) ## this isn't working when column names are in quotes

  locate <- grant_df[search_in]

  s <- grant_df[with(grant_df, grepl(query, locate)),] ## this is not vectorising for some reason

  ## if search_in length > 1, look in multiple columns

}
