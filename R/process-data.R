
#' Convert data to tibble
#'
#' Given a list returned by [tsg_all_grants()] or [tsg_search_grants()],
#' creates a tibble with all available variables. This tibble contains roughly
#' 200 columns if all
#' available grants are used (as of October 2019), due to differences in
#' how grant data is labelled and structured.
#'
#' @seealso tsg_core_data
#'
#' @param min_coverage A number from 0 to 1. If >0, only returns variables
#' with a value other than `NA` for at least that proportion of rows. Defaults
#' to 0 and returns all columns
#' @inheritParams tsg_core_data
#'
#' @return A tibble with all variables from all grants.
#' @export
#'
#' @examples
#' \dontrun{
#' grants <- tsg_all_grants()
#'
#' df <- tsg_process_data(grants)
#' }
#'
tsg_process_data <- function(x, min_coverage = 0, verbose = TRUE) {
  df <- tsg_core_process(x, verbose, process_type = "all")

  if (min_coverage > 0) {
    if (min_coverage > 1 | min_coverage < 0) {
      message("`min_coverage` must be a number from 0 to 1.
              All columns will be returned")
    } else {
      d <- purrr::map(df, ~ sum(is.na(.)))

      min_df <- data.frame("value" = unlist(d), "names" = names(d))

      min_df$perc <- min_df$value / nrow(df)

      min_df <- min_df[min_df$perc <= min_coverage, ]

      df <- df[names(df) %in% min_df$names]
    }
  }

  df
}
