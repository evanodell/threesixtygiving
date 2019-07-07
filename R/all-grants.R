


#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @param verbose If `TRUE`, prints console messages.
#'
#' @return A list of data frames.
#' @export
#'
#' @examples \donttest{
#'
#' all_grants <- tsg_all_grants()
#'
#' }
tsg_all_grants <- function(verbose = TRUE) {
  grant_df <- tsg_available()

  #suffix <- list()

  spend_df <- list()

  for (i in seq_along(grant_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(grant_df$title)))
    }

    suffix <- sub(".*\\.", "", substr(grant_df$downloadURL[[i]],
                                      (nchar(grant_df$downloadURL[[i]]) - 3),
                                      nchar(grant_df$downloadURL[[i]]) ))

    temp_f <- tempfile()

    download.file(grant_df$downloadURL[[i]], temp_f,
                  mode = "wb", quiet = !verbose)

      if (!(suffix %in% c("xlsx", "csv", "json"))) {
        df_x <- curl::curl_fetch_memory(grant_df$downloadURL[[i]])
        if (df_x$type == "text/csv") {
          spend_df[[i]] <- read.csv(grant_df$downloadURL[[i]],
                                    colClasses = "character") ## because mostly CSVs
        } else {

          spend_df[[i]] <- tryCatch({ ## majority of returns
            spend_df[[i]] <- readxl::read_excel(temp_f, col_types = "text")
          },
          error = function(cond) {
            return("Download failed")
          } )

          spend_df[[i]]$tsg_identifier <- grant_df$identifier[[i]]

          }

      } else {

        if (suffix == "xlsx") {
        spend_df[[i]] <- tryCatch({ ## majority of returns
          spend_df[[i]] <- readxl::read_excel(temp_f, col_types = "text")
        },
        error = function(cond) {
          return("Download failed")
        } )

        spend_df[[i]]$tsg_identifier <- grant_df$identifier[[i]]
      } else if (suffix == "csv") { ## some csv returns
        spend_df[[i]] <- tryCatch({
          dplyr::as_tibble(read.csv(temp_f, colClasses = "character"))
        },
        error = function(cond) {
          return("Download failed")
        }
        )

        spend_df[[i]]$tsg_identifier <- grant_df$identifier[[i]]
      } else if (suffix == "json") { ## only a handful of JSON files
        spend_df[[i]] <- tryCatch({
          jsonlite::fromJSON(grant_df$downloadURL[[i]])
        },
        error = function(cond) {
          return("Download failed")
        }
        )

        if (is.list(spend_df[[i]])) {
          spend_df[[i]] <- spend_df[[i]]$grants

          spend_df[[i]][, ] <- lapply(spend_df[[i]][, ], as.character)
        }

        spend_df[[i]]$tsg_identifier <- grant_df$identifier[[i]]
      }

      }

      names(spend_df[[i]]) <- snakecase::to_snake_case(names(spend_df[[i]]))


      }

  df <- dplyr::bind_rows(spend_df)
}


