


tsg_all_grants <- function(verbose = TRUE) {

  grant_df <- tsg_available()

  grant_df$spend <- NA

  suffix <- list()

  spend_df <- list()

  for (i in seq_along(grant_df$spend)) {

    if (verbose) {
    message(paste0("Downloading ", i, " of ", length(grant_df$spend)))
    }

    url_lookup <- grant_df$downloadURL[[i]]

    suffix <- sub('.*\\.', '', url_lookup)

    if (suffix == "xlsx") {

      spend_df[[i]] <- tryCatch({

        openxlsx::read.xlsx(grant_df$downloadURL[[i]])

      },
      error = function(cond) {
        return("Download failed")
      }
      )

      spend_df[[i]]$tsg_identifier <-grant_df$identifier[[i]]

    } else if (suffix == "csv"){

      spend_df[[i]] <- tryCatch({

        read.csv(grant_df$downloadURL[[i]])

      },
      error = function(cond) {
        return("Download failed")
      }
      )

      spend_df[[i]]$tsg_identifier <-grant_df$identifier[[i]]

    } else if (suffix == "json"){

      spend_df[[i]] <- tryCatch({

        jsonlite::fromJSON(grant_df$downloadURL[[i]])

      },
      error = function(cond) {
        return("Download failed")
      }
      )

      spend_df[[i]]$tsg_identifier <-grant_df$identifier[[i]]
    } else {

      spend_df[[i]] <- tryCatch({

      read.csv(grant_df$downloadURL[[i]])

      },
      )

    }

  }


  f <- tempdir()

  x <- openxlsx::read.xlsx("https://www.trustforlondon.org.uk/documents/467/FinalTrust_for_London_Grants_List_2018.xlsx")

  f <- tempfile(fileext = ".xlsx")

  download.file(grant_df$downloadURL[[i]], paste0(tempdir(), i,".xlsx"), mode = "wb")

  x <- openxlsx::read.xlsx(paste0(tempdir(), i,".xlsx"))

  data_dir <- "tmp"

  f <- file.path(tempdir(), grant_df$downloadURL[[i]])

  download.file(grant_df$downloadURL[[i]], destfile = "tmp/i.xlsx")



}


