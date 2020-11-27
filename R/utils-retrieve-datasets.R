
## Retrieve datasets for all specified datasets. Accepts returns of
# tsg_available and tsg_specific_data
tsg_data_retrieval <- function(query_df, verbose = verbose, timeout = 30,
                               retries = 0, correct_names = TRUE) {
  g_list <- list()

  for (i in seq_along(query_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(query_df$title)))
    }

    suffix <- query_df$data_type[[i]]

    if (suffix %in% c("xlsx", "csv", "json", "xls")) {
      temp_f <- tempfile(fileext = paste0(".", suffix))
    } else {
      temp_f <- tempfile()
    }

    result <- tryCatch( # Check availability
      {
        httr::RETRY("GET", query_df$download_url[[i]],
          httr::user_agent("Mozilla/5.0"),
          httr::write_disk(temp_f, overwrite = TRUE),
          times = retries,
          httr::timeout(timeout), terminate_on_success = FALSE
        )
      },
      error = function(cond) {
        return(NA)
      }
    )

    suffix <- ifelse((suffix == "unknown" && all(!is.na(result))),
      sub(".*/", "", result$headers$`content-type`),
      suffix
    )

    if (grepl("json", suffix)) {
      suffix <- "json"
    }

    if (class(result) != "response") {
      if (verbose) message("Could not connect to server")
      g_list[[i]] <- tibble::tibble()
    } else if (httr::status_code(result) == 403) {
      data_dir <- tempdir()

      destfile <- file.path(data_dir, basename(query_df$download_url[[i]]))

      curl::curl_download(query_df$download_url[[i]], destfile)
      if (suffix == "csv") {
        g_list[[i]] <- readr::read_csv(
          destfile,
          col_types = readr::cols(.default = "c")
        )
      } else if (suffix %in% c("xlsx", "xls")) {
        g_list[[i]] <- tsg_excel(destfile)
      } else if (suffix == "json") {
        g_list[[i]] <- tsg_json(destfile)
      }
    } else if (!(httr::status_code(result) %in% c(200, 403))) {
      resp <- httr::http_status(result)
      message("Request failed: ", resp$message)
      g_list[[i]] <- tibble::tibble()
    } else {
      if (!(suffix %in% c("xlsx", "csv", "json", "xls"))) {
        if (result$headers$`content-type` == "text/csv") {
          g_list[[i]] <- readr::read_csv(
            temp_f,
            col_types = readr::cols(.default = "c")
          )
        } else if (result$headers$`content-type` == "application/json") {
          g_list[[i]] <- tsg_json(temp_f)
        } else {
          g_list[[i]] <- tsg_excel(temp_f)
        }
      } else {
        if (suffix %in% c("xlsx", "xls")) {
          g_list[[i]] <- tsg_excel(temp_f)
        } else if (suffix == "csv") { ## some csv returns
          g_list[[i]] <- tryCatch(
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
        } else if (suffix == "json") {
          g_list[[i]] <- tsg_json(temp_f)
        }
      }
    }

    if (is.data.frame(g_list[[i]]) & length(g_list[[i]]) > 1) {
      g_list[[i]] <- janitor::remove_empty(
        janitor::clean_names(g_list[[i]]),
        which = c("rows", "cols")
      )

      g_list[[i]]$publisher_prefix <- query_df$publisher_prefix[[i]]
      g_list[[i]]$data_type <- suffix
      g_list[[i]]$license_name <- query_df$license_name[[i]]
      g_list[[i]]$license <- query_df$license[[i]]
      g_list[[i]]$dataset_id <- query_df$identifier[[i]]

      if (correct_names == TRUE) { ## Name corrections
        # The stringi option is about four times faster than base option
        if (requireNamespace("stringi", quietly = TRUE)) {
          names(g_list[[i]]) <- stringi::stri_replace_all_fixed(
            names(g_list[[i]]),
            c("recepient", "benificiary", "sponsor_s"),
            c("recipient", "beneficiary", "sponsors"),
            vectorize_all = FALSE
          )
        } else {
          names(g_list[[i]]) <- gsub(
            "recepient", "recipient",
            names(g_list[[i]])
          )
          names(g_list[[i]]) <- gsub(
            "benificiary", "beneficiary",
            names(g_list[[i]])
          )
          names(g_list[[i]]) <- gsub(
            "sponsor_s", "sponsors",
            names(g_list[[i]])
          )
        }
      }

      # Handle weird naming problem
      if ("identifier_2" %in% colnames(g_list[[i]]) &&
        !("identifier" %in% colnames(g_list[[i]]))) {
        names(g_list[[i]]) <- gsub("identifier_2", "identifier",
          names(g_list[[i]]),
          fixed = TRUE
        )
      }

      if (suffix == "json") {
        names(g_list[[i]]) <- gsub(
          "^id$", "identifier",
          names(g_list[[i]])
        )
      }

      if (suffix %in% c("xls", "xlsx")) {
        g_list[[i]]$award_date <- as.Date(anytime::anydate(ifelse(
          is.na(as.Date(strptime(g_list[[i]]$award_date,
            format = "%Y-%m-%d"
          ))),
          suppressWarnings(janitor::excel_numeric_to_date(
            as.numeric(as.character(g_list[[i]]$award_date))
          )),
          as.Date(strptime(g_list[[i]]$award_date, format = "%Y-%m-%d"))
        )))
      } else {
        g_list[[i]]$award_date <- as.Date(g_list[[i]]$award_date)
      }
      # Fix weird amounts stuff
      g_list[[i]]$amount_awarded <- gsub(
        "k", "000",
        g_list[[i]]$amount_awarded,
        ignore.case = TRUE
      )
      # Make award amounts an integer
      g_list[[i]]$amount_awarded <- as.integer(g_list[[i]]$amount_awarded)
    }
  }

  for (i in seq_along(g_list)) {
    if (length(g_list[[i]]) == 0) {
      g_list[[i]] <- NA
    }
  }

  g_list <- g_list[!is.na(g_list)]

  if (verbose) {
    m_df <- query_df[!(query_df$identifier %in%
      unique(unlist(purrr::map(g_list, "dataset_id")))), ]

    if (nrow(query_df) != length(g_list)) {
    message(
      "The following datasets (Title and Identifier) did not download:\n",
      paste(m_df$title, m_df$identifier, "\n")
    )
    }
  }

  g_list
}
