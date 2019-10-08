
#' Available datasets
#'
#' Information on the available datasets
#'
#' @return A tibble with details on all available datasets.
#' @export
#'
#' @examples
#' \donttest{
#' available <- tsg_available()
#' }
#'
tsg_available <- function() {
  url <- "http://data.threesixtygiving.org/data.json"

  df <- dplyr::as_tibble(jsonlite::fromJSON(url, flatten = TRUE))

  df$distribution <- lapply(df$distribution, dplyr::as_tibble)

  df$distribution <- lapply(df$distribution, janitor::clean_names)

  df <- janitor::clean_names(df)

  df
}
