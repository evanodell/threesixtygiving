
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

  df <- tibble::as_tibble(jsonlite::fromJSON(url, flatten = TRUE))

  df$distribution <- lapply(df$distribution, tibble::as_tibble)

  df$distribution <- lapply(df$distribution, janitor::clean_names)

  df <- janitor::clean_names(df)

  for (i in seq_along(df$title)) {
    df$distribution[[i]]$data_type <- sub(
      ".*\\.", "",
      substr(
        df$distribution[[i]]$download_url,
        (nchar(df$distribution[[i]]$download_url) - 3),
        nchar(df$distribution[[i]]$download_url)
      )
    )

    if (!(df$distribution[[i]]$data_type %in% c("json", "csv", "xlsx", "xls"))) {
      df$distribution[[i]]$data_type <- "unknown"
    }
  }

  df
}
