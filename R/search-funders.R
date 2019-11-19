

#' Search funders
#'
#' Return a tibble with information on all grant datasets where funder data
#' matches one or more search strings.
#'
#' @param search The string(s) to search for. By default allows POSIX 1003.2
#' regular expressions. Use `perl = TRUE` for perl-style regex, or
#' `fixed = TRUE` for fixed strings.
#' Accepts single strings or a character vector of strings.
#' @param search_in The name of the column to search in. Accepts single strings
#'  or a character vector of column names. If `NULL`, searches all columns.
#' @inheritParams tsg_all_grants
#' @param ignore_case If `TRUE` ignores case.
#' @param perl If `TRUE`, uses perl-style regex.
#' @param fixed If `TRUE`, searches will be matched as-is.
#'
#' @return A tibble with information on matching datasets
#'
#' @seealso [tsg_search_grants()] for retrieving all grants
#' from matching funders.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' search1 <- tsg_search_funders(search = c("bbc", "caBinet"))
#' }
#'
tsg_search_funders <- function(search, search_in = NULL, verbose = TRUE,
                               ignore_case = TRUE, perl = FALSE,
                               fixed = FALSE) {
  grant_df <- tsg_available()

  query <- paste0(search, collapse = "|")

  if (is.null(search_in)) {
    search_in <- names(grant_df)
  } else {
    if (!all(search_in %in% names(grant_df))) {
      stop("`search_in` must either be NULL or a character vector of values
           matching column names returned by `tsg_available()`", call. = FALSE)
    }
  }

  temp <- sapply(
    grant_df[search_in],
    function(x) {
      grepl(query, x,
        ignore.case = ignore_case,
        perl = perl, fixed = fixed
      )
    }
  )

  return <- grant_df[rowSums(temp) > 0L, ]

  return
}
