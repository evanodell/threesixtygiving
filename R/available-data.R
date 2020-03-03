
#' Available datasets
#'
#' Returns a tibble with information on all datasets available through
#' 360Giving. Some funders have multiple datasets
#'
#' @return A tibble with details on all available datasets.
#'
#' @export
#'
#' @examples
#' \dontrun{
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

    if (!(df$distribution[[i]]$data_type %in% c(
      "json", "csv",
      "xlsx", "xls"
    ))) {
      url_check <- sub(
        ".*\\.", "",
        substr(
          df$distribution[[i]]$access_url,
          (nchar(df$distribution[[i]]$access_url) - 3),
          nchar(df$distribution[[i]]$access_url)
        )
      )

      if (url_check %in% c("json", "csv", "xlsx", "xls")) {
        url_hold <- df$distribution[[i]]$download_url
        df$distribution[[i]]$download_url <- df$distribution[[i]]$access_url
        df$distribution[[i]]$access_url <- url_hold
        df$distribution[[i]]$data_type <- url_check
      } else {
        df$distribution[[i]]$data_type <- "unknown"
      }
    }

    # if (grepl("glasgow", df$publisher_name[[i]], ignore.case = TRUE)) {
    #   df$distribution[[i]]$download_url <- gsub(
    #     "http:", "https:", df$distribution[[i]]$download_url, fixed = TRUE
    #     )
    # }

    df$distribution[[i]]$title <- NULL
  }

  df <- tidyr::unnest_wider(df, col = "distribution")

  df$modified <- as.POSIXct(gsub("T", " ", df$modified))

  df$issued <- as.Date(df$issued)

  df
}
