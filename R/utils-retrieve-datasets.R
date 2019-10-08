
## Retrieve datasets for all specified datasets. Accepts returns of tsg_available and
# tsg_specific_data
tsg_data_retrieval <- function(query_df, verbose = verbose) {

  query_df$id2 <- c(1:nrow(query_df))

  spend_df <- list()

  for (i in seq_along(query_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(query_df$title)))
    }

    suffix <- sub(".*\\.", "", substr(query_df$download_url[[i]],
                                      (nchar(query_df$download_url[[i]]) - 3),
                                      nchar(query_df$download_url[[i]]) ))

    temp_f <- tempfile()

    resp <- httr::GET(query_df$download_url[[i]],
              httr::write_disk(temp_f, overwrite=TRUE))

    if (httr::http_error(resp)) {
    warning(paste0("For file ", i, " request returns error code: ",
                   httr::status_code(resp)))
      spend_df[[i]] <- httr::status_code(resp)

    } else {

    # tryCatch({
    #   download.file(query_df$download_url[[i]], temp_f,
    #                 mode = "wb", quiet = TRUE)
    # },
    # error = function(cond) {
    #   message(
    #     "It is likely that you have been automatically rate limited ",
    #     "by the Nomis API.\n",
    #     "You can make smaller data requests, or try again later.\n\n",
    #     "Here's the original error message:\n", cond
    #   )
    #
    #   return(NA)
    # }
    # )

    if (!(suffix %in% c("xlsx", "csv", "json"))) {
      df_x <- curl::curl_fetch_memory(query_df$download_url[[i]])
      if (df_x$type == "text/csv") {
        spend_df[[i]] <- readr::read_csv(
          temp_f, col_types = readr::cols(.default = "c")
          )
      } else {

        spend_df[[i]] <- tryCatch({ ## majority of returns
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
          jsonlite::fromJSON(query_df$download_url[[i]], flatten = FALSE)
        },
        error = function(cond) {
          return("Download failed")
        }
        )

        if (is.list(spend_df[[i]]) && is.data.frame(spend_df[[i]][[1]])) {
          spend_df[[i]] <- dplyr::as_tibble(spend_df[[i]][[1]])
        }
      }

    }

    names(spend_df[[i]]) <- snakecase::to_snake_case(names(spend_df[[i]]))

    spend_df[[i]]$id2 <- i

    spend_df[[i]] <- dplyr::mutate_if(spend_df[[i]], is.numeric, as.character)

    # insert an option to do this or not?
#
#       if (any(lapply(spend_df[[i]], class)=="list")) {
#
#      #   spend_df[[i]] <- tidyr::unnest(spend_df[[i]], .sep = "_")
#      #
#      #   # Need to figure out how to process all these
#      #
#         x_list <- dplyr::select_if(spend_df[[i]], is.list) # select list cols
#
#         # x_list2 <- sapply(x_list, bind_rows)
#         #
#         # x_list3 <- sapply(x_list2, unnest, .sep = "_")
#
#         de <- dplyr::as_tibble(lapply(x_list, sapply, nrow))
#
#         de <- de %>%
#           dplyr::mutate_if(is.list, as.character) %>%
#           dplyr::mutate_if(is.character, as.numeric) %>%
#           dplyr::select(which(colMeans(., na.rm = TRUE) <= 1))
#
#         #de[is.na(de)] <- 0
#
#         de2 <- dplyr::as_tibble(lapply(x_list, sapply, length))
#
#         de2 <- de2 %>%
#           dplyr::mutate_if(is.list, as.character) %>%
#           dplyr:: mutate_if(is.character, as.numeric)  %>%
#           dplyr::select(dplyr::one_of(names(de))) %>%
#           dplyr::select(which(colMeans(., na.rm = TRUE) <= 1))
#
#         #x_list[x_list == "NULL"] <- tibble::tibble(a = character())
#
#         x_list[x_list == "NULL"] <- NA
#         #
#         # summary(lapply(x_list, is.na))
#         #
#         # rrr <-rapply( x_list, f=function(x) ifelse(is.na(x),0,x), how="replace" )
#
#         x_list2 <- x_list %>%
#            dplyr::select(names(de))  %>%
#            dplyr::mutate_at(dplyr::vars(names(de2)), unlist)  %>%
#            dplyr::mutate_at(dplyr::vars(names(de2)), as.list)
#
#          y_list <- purrr::map_if(x_list2, is.list, dplyr::bind_rows) %>%
#            dplyr::as_tibble() %>%
#            jsonlite::flatten() %>%
#            dplyr::as_tibble() %>%
#            janitor::remove_empty(which = "cols")
#
#          x_list3 <- dplyr::select(x_list, -dplyr::one_of(names(x_list2)))
#
#          orig_df <- dplyr::select(spend_df[[i]], -dplyr::one_of(names(x_list)))
#
#          spend_df[[i]] <- dplyr::bind_rows(orig_df, y_list, x_list3)
#
#       }

    }

  }

  #names(spend_df) <- query_df$identifier

  spend_df

}
