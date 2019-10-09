
## Retrieve datasets for all specified datasets. Accepts returns of tsg_available and
# tsg_specific_data
tsg_data_retrieval <- function(query_df, verbose = verbose, timeout = timeout) {
  query_df$id2 <- c(1:nrow(query_df))

  spend_df <- list()

  # handle360 <- curl::new_handle()
  #
  # curl::handle_setopt(handle360, timeout_ms = 10000);

  for (i in seq_along(query_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(query_df$title)))
    }

    suffix <- sub(
      ".*\\.", "",
      substr(
        query_df$distribution[[i]]$download_url,
        (nchar(query_df$distribution[[i]]$download_url) - 3),
        nchar(query_df$distribution[[i]]$download_url)
      )
    )

     temp_f <- tempfile()

     result <- tryCatch({ ## majority of returns

     httr::RETRY("GET", query_df$distribution[[i]]$download_url,
                      httr::write_disk(temp_f, overwrite=TRUE),
                      httr::timeout(timeout), terminate_on_success = FALSE)

      # x <- httr::GET(query_df$distribution[[i]]$download_url,
      #            httr::write_disk(temp_f, overwrite=TRUE),
      #            httr::timeout(timeout))#, col_types = "text"
      },
      error = function(cond) {
        return(NA)
      }
     )

     if (httr::status_code(result) != 200) {

       spend_df[[i]] <- NA

     } else {

    #
    #R.utils::withTimeout(
       # curl::curl_download(query_df$distribution[[i]]$download_url, temp_f,
       #                     mode = "wb", quiet = TRUE)#,# handle = handle360)
    # timeout = 25, onTimeout = "warning") ## initial download, find some way to return error and skip things when this fails

    if (!(suffix %in% c("xlsx", "csv", "json", "xls"))) {
      df_x <- curl::curl_fetch_memory(query_df$distribution[[i]]$download_url)
      if (df_x$type == "text/csv") {
        spend_df[[i]] <- readr::read_csv(
          temp_f,
          col_types = readr::cols(.default = "c")
        )
      } else {
        spend_df[[i]] <- tryCatch({ ## majority of returns
          readxl::read_excel(temp_f)#, col_types = "text"
        },
        error = function(cond) {
          return(NA)
        }
        )
      }
    } else {
      if (suffix %in% c("xlsx", "xls")) {
        spend_df[[i]] <- tryCatch({ ## majority of returns
          readxl::read_excel(temp_f)#, col_types = "text"
        },
        error = function(cond) {
          return(NA)
        }
        )
      } else if (suffix == "csv") { ## some csv returns
        spend_df[[i]] <- tryCatch({
          dplyr::as_tibble(readr::read_csv(
            temp_f,
            col_types = readr::cols(.default = "c")
          ))
        },
        error = function(cond) {
          return(NA)
        }
        )
      } else if (suffix == "json") { ## only a handful of JSON files
        spend_df[[i]] <- tryCatch({
          jsonlite::fromJSON(query_df$distribution[[i]]$download_url,
                             flatten = TRUE
          )
        },
        error = function(cond) {
          return(NA)
        }
        )

        if (is.list(spend_df[[i]]) && is.data.frame(spend_df[[i]][[1]])) {
          spend_df[[i]] <- dplyr::as_tibble(spend_df[[i]][[1]])
        }
      }
    }

    if (is.data.frame(spend_df[[i]])) {

    spend_df[[i]] <- janitor::clean_names(spend_df[[i]])

    #spend_df[[i]] <- dplyr::mutate_if(spend_df[[i]], is.numeric, as.character)
    #Not sure why the commented otu function above is included, should note the
    #rationale if there is one

    ## some kind of mutate-if for values containing dates

    spend_df[[i]]$publisher_prefix <- query_df$publisher_prefix[[i]]
    }
     }

  }

  spend_df
}
