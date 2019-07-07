
#' Available datasets
#'
#' @return A data frame with available datasets
#' @export
#'
#' @examples
#'
tsg_available <- function() {
  url <- "http://data.threesixtygiving.org/data.json"

  df <- jsonlite::fromJSON(url, flatten = TRUE)

  df2 <- dplyr::inner_join(df, dplyr::bind_rows(df$distribution), by = "title")

  df2$distribution <- NULL

  names(df2) <- snakecase::to_snake_case(names(df2))

  df2
}
