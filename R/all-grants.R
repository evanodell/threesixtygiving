


tsg_all_grants <- function(verbose = TRUE) {
  grant_df <- tsg_available()

  #suffix <- list()

  spend_df <- list()

  for (i in seq_along(grant_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(grant_df$title)))
    }

    url_lookup <- grant_df$downloadURL[[i]]

    suffix <- sub(".*\\.", "", url_lookup)

    if (suffix == "xlsx") {
      spend_df[[i]] <- tryCatch({ ## majority of returns
        openxlsx::read.xlsx(grant_df$downloadURL[[i]])
      },
      error = function(cond) {
        return("Download failed")
      }
      )

      spend_df[[i]]$tsg_identifier <- grant_df$identifier[[i]]
    } else if (suffix == "csv") { ## some csv returns
      spend_df[[i]] <- tryCatch({
        read.csv(grant_df$downloadURL[[i]])
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

      spend_df[[i]]$tsg_identifier <- grant_df$identifier[[i]]
    } else { ## mostly CSVs but could be others

      spend_df[[i]] <- read.csv(grant_df$downloadURL[[i]]) ## because mostly CSVs

      ## Need to create some kind of error handling process for the non-csvs


      df_x <- curl::curl_fetch_memory(grant_df$downloadURL[[i]])
      if (df_x$type == "text/csv") {

      }

       df_x


      df_y <- httr::GET(grant_df$downloadURL[[i]])

      data.frame(rawToChar(df_y$content))

    }
  }


  # f <- tempdir()
  #
  # x <- openxlsx::read.xlsx("https://www.trustforlondon.org.uk/documents/467/FinalTrust_for_London_Grants_List_2018.xlsx")
  #
  # f <- tempfile(fileext = ".xlsx")
  #
  #
  #
  #
  #
  # data_dir <- "tmp"
  #
  # f <- file.path(tempdir(), grant_df$downloadURL[[i]])
  #
  # download.file(grant_df$downloadURL[[i]], destfile = "tmp/i.xlsx")
}
