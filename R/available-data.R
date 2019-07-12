
#' Available datasets
#'
#' Information on the available datasets
#'
#' @return A tibble with details on all available datasets.
#' @export
#'
#' @examples \donttest{
#' available <- tsg_available()
#' }

tsg_available <- function() {
  url <- "http://data.threesixtygiving.org/data.json"

  df <- jsonlite::fromJSON(url, flatten = TRUE)

  df2 <- dplyr::as_tibble(
    dplyr::inner_join(df, dplyr::bind_rows(df$distribution), by = "title")
    )

  df2$distribution <- NULL

  names(df2) <- snakecase::to_snake_case(names(df2))

  df2
}
