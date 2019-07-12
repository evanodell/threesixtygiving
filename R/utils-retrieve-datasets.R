
## Retrieve datasets for all specified datasets. Accepts returns of tsg_available and
# tsg_specific_data
tsg_data_retrieval <- function(query_df, verbose = verbose) {

  spend_df <- list()

  for (i in seq_along(query_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(query_df$title)))
    }

    suffix <- sub(".*\\.", "", substr(query_df$download_url[[i]],
                                      (nchar(query_df$download_url[[i]]) - 3),
                                      nchar(query_df$download_url[[i]]) ))

    temp_f <- tempfile()

    download.file(query_df$download_url[[i]], temp_f,
                    mode = "wb", quiet = !verbose)

    if (!(suffix %in% c("xlsx", "csv", "json"))) {
      df_x <- curl::curl_fetch_memory(query_df$download_url[[i]])
      if (df_x$type == "text/csv") {
        spend_df[[i]] <- readr::read_csv(
          temp_f, col_types = readr::cols(.default = "c")
          )
      } else {

        spend_df[[query_df$identifier[[i]]]] <- tryCatch({ ## majority of returns
          readxl::read_excel(temp_f, col_types = "text")
        },
        error = function(cond) {
          return("Download failed")
        } )
      }

    } else {

      if (suffix == "xlsx") {
        spend_df[[i]] <- tryCatch({ ## majority of returns
         readxl::read_excel(temp_f, col_types = "text")
        },
        error = function(cond) {
          return("Download failed")
        } )
      } else if (suffix == "csv") { ## some csv returns
        spend_df[[i]] <- tryCatch({
          dplyr::as_tibble(readr::read_csv(
            temp_f, col_types = readr::cols(.default = "c"))
            )
        },
        error = function(cond) {
          return("Download failed")
        }
        )
      } else if (suffix == "json") { ## only a handful of JSON files
        spend_df[[i]] <- tryCatch({
          jsonlite::fromJSON(query_df$download_url[[i]])
        },
        error = function(cond) {
          return("Download failed")
        }
        )

        if (is.list(spend_df[[i]])) {
          spend_df[[i]] <- spend_df[[i]]$grants

          spend_df[[i]][, ] <- lapply(spend_df[[i]][, ], as.character)
        }
      }

    }

    names(spend_df[[i]]) <- snakecase::to_snake_case(names(spend_df[[i]]))

  }

  names(spend_df) <- query_df$identifier

  spend_df

}
