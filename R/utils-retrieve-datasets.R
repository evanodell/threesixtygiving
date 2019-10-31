
## Retrieve datasets for all specified datasets. Accepts returns of
# tsg_available and tsg_specific_data
tsg_data_retrieval <- function(query_df, verbose = TRUE, timeout = 30,
                               retries = 3, correct_names = TRUE) {
  spend_df <- list()

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

    result <- tryCatch( # Check availability
      {
        httr::RETRY("GET", query_df$distribution[[i]]$download_url,
          httr::write_disk(temp_f, overwrite = TRUE),
          times = retries,
          httr::timeout(timeout), terminate_on_success = FALSE
        )
      },
      error = function(cond) {
        return(NA)
      }
    )

    if (class(result) != "response") {
      if (verbose) message("Could not connect to server")
      spend_df[[i]] <- tibble::tibble()
    } else if (httr::status_code(result) != 200) {
      resp <- httr::http_status(result)

      message("Request failed: ", resp$message)

      spend_df[[i]] <- tibble::tibble()
    } else {
      if (!(suffix %in% c("xlsx", "csv", "json", "xls"))) {
        if (result$headers$`content-type` == "text/csv") {
          spend_df[[i]] <- readr::read_csv(
            temp_f,
            col_types = readr::cols(.default = "c")
          )
        } else {
          spend_df[[i]] <- tryCatch(
            { ## majority of returns
              readxl::read_excel(temp_f, guess_max = 21474836)
            },
            error = function(cond) {
              return(NA)
            }
          )
        }
      } else {
        if (suffix %in% c("xlsx", "xls")) {
          spend_df[[i]] <- tryCatch(
            { ## majority of returns
              if (length(readxl::excel_sheets(temp_f)) > 1) {
                multi <- lapply(readxl::excel_sheets(temp_f),
                  readxl::read_excel,
                  path = temp_f,
                  guess_max = 21474836
                )

                s_rows <- nrow(multi[[1]])

                s_list <- list()
                for (k in seq_along(multi)) {
                  if (nrow(multi[[k]]) == s_rows) {
                    s_list[[k]] <- multi[[k]]
                  }
                }
                s_list[sapply(s_list, is.null)] <- NULL

                s <- purrr::reduce(s_list, dplyr::inner_join)
              } else {
                s <- readxl::read_excel(temp_f, guess_max = 21474836)
              }

              s
            },
            error = function(cond) {
              return(NA)
            }
          )
        } else if (suffix == "csv") { ## some csv returns
          spend_df[[i]] <- tryCatch(
            {
              tibble::as_tibble(readr::read_csv(
                temp_f,
                col_types = readr::cols(.default = "c")
              ))
            },
            error = function(cond) {
              return(NA)
            }
          )
        } else if (suffix == "json") { ## only a handful of JSON files
          spend_df[[i]] <- tryCatch(
            {
              jsonlite::fromJSON(query_df$distribution[[i]]$download_url,
                flatten = FALSE
              )
            },
            error = function(cond) {
              return(NA)
            }
          )

          if (is.list(spend_df[[i]]) && is.data.frame(spend_df[[i]][[1]])) {
            spend_df[[i]] <- tibble::as_tibble(spend_df[[i]][[1]])
          }
        }
      }

      if (is.data.frame(spend_df[[i]]) & length(spend_df[[i]]) > 1) {
        spend_df[[i]] <- janitor::clean_names(spend_df[[i]])
        spend_df[[i]] <- janitor::remove_empty(spend_df[[i]], which = "cols")
        spend_df[[i]] <- janitor::remove_empty(spend_df[[i]], which = "rows")

        spend_df[[i]]$publisher_prefix <- query_df$publisher_prefix[[i]]
        spend_df[[i]]$data_type <- suffix
        spend_df[[i]]$license_name <- query_df$license_name[[i]]

        if (correct_names == TRUE) {
          names(spend_df[[i]]) <- stringi::stri_replace_all_fixed(
            names(spend_df[[i]]),
            c("recepient", "benificiary", "sponsor_s"),
            c("recipient", "beneficiary", "sponsors"),
            vectorize_all = FALSE
          )
        }

        # Handle weird naming problem
        if (any(spend_df[[i]]$publisher_prefix == "360G-BirminghamCC")) {
          names(spend_df[[i]]) <- gsub("identifier_2", "identifier",
            names(spend_df[[i]]),
            fixed = TRUE
          )
        }

        if (suffix == "json") {
          names(spend_df[[i]]) <- gsub(
            "^id$", "identifier",
            names(spend_df[[i]])
          )
        }

        if (suffix %in% c("xls", "xlsx")) {
          spend_df[[i]]$award_date <- as.Date(anytime::anydate(ifelse(
            is.na(as.Date(strptime(spend_df[[i]]$award_date,
              format = "%Y-%m-%d"
            ))),
            suppressWarnings(janitor::excel_numeric_to_date(
              as.numeric(as.character(spend_df[[i]]$award_date))
            )),
            as.Date(strptime(spend_df[[i]]$award_date, format = "%Y-%m-%d"))
          )))
        } else {
          spend_df[[i]]$award_date <- as.Date(spend_df[[i]]$award_date)
        }

        spend_df[[i]]$amount_awarded[is.na(spend_df[[i]]$amount_awarded)] <- 0

        # Fix weird amounts stuff
        spend_df[[i]]$amount_awarded <- gsub(
          "k", "000",
          spend_df[[i]]$amount_awarded,
          ignore.case = TRUE
        )

        spend_df[[i]]$amount_awarded <- as.integer(
          spend_df[[i]]$amount_awarded
        )
      }
    }
  }
  spend_df
}
