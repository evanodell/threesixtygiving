
## Retrieve datasets for all specified datasets. Accepts returns of tsg_available and
# tsg_specific_data
tsg_data_retrieval <- function(query_df, verbose = verbose) {

  query_df$id2 <- c(1:nrow(query_df))

  spend_df <- list()

  for (i in seq_along(query_df$title)) {
    if (verbose) {
      message(paste0("Downloading ", i, " of ", length(query_df$title)))
    }

    suffix <- sub(".*\\.", "",
                  substr(query_df$distribution[[i]]$download_url,
                         (nchar(query_df$distribution[[i]]$download_url) - 3),
                         nchar(query_df$distribution[[i]]$download_url)))

    temp_f <- tempfile()

    curl::curl_download(query_df$distribution[[i]]$download_url, temp_f,
                    mode = "wb", quiet = !verbose)

    if (!(suffix %in% c("xlsx", "csv", "json"))) {
      df_x <- curl::curl_fetch_memory(query_df$distribution[[i]]$download_url)
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
          jsonlite::fromJSON(query_df$distribution[[i]]$download_url,
                             flatten = TRUE)
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

    spend_df[[i]] <- janitor::clean_names(spend_df[[i]])

    spend_df[[i]] <- dplyr::mutate_if(spend_df[[i]], is.numeric, as.character)

    spend_df[[i]]$publisher_prefix <- query_df$publisher_prefix[[i]]
  }

  spend_df

}


# insert an option to do this or not?

# if (any(lapply(spend_df[[i]], class)=="list")) {
#   x_list <- dplyr::select_if(s, is.list) # select list cols
#
#
#    x_list <- dplyr::select_if(spend_df[[i]], is.list) # select list cols
#
#    de <- dplyr::as_tibble(lapply(x_list, sapply, nrow))
#
#    de <- de %>%
#      dplyr::mutate_if(is.list, as.character) %>%
#      dplyr:: mutate_if(is.character, as.numeric) %>%
#      dplyr::select(which(colMeans(., na.rm = TRUE) <= 1))
#
#    de2 <- dplyr::as_tibble(lapply(x_list, sapply, length))
#
#    de2 <- de2 %>%
#      dplyr::mutate_if(is.list, as.character) %>%
#      dplyr:: mutate_if(is.character, as.numeric)  %>%
#      dplyr::select(one_of(names(de))) %>%
#      dplyr::select(which(colMeans(., na.rm = TRUE) <= 1))
#
#    #x_list[x_list == "NULL"] <- tibble::tibble(a = character())
#
#    x_list[x_list == "NULL"] <- NA
#
#    lapply(x_list, is.na)
#
#    rrr <-rapply( x_list, f=function(x) ifelse(is.na(x),0,x), how="replace" )
#
#    x_list2 <- x_list %>%
#       dplyr::select(names(de))  %>%
#       dplyr::mutate_at(vars(names(de2)), unlist)  %>%
#       dplyr::mutate_at(vars(names(de2)), as.list)
#
#     y_list <- purrr::map_if(x_list2, is.list, bind_rows) %>%
#       dplyr::as_tibble() %>%
#       jsonlite::flatten() %>%
#       dplyr::as_tibble() %>%
#       janitor::remove_empty(which = "cols")
#
#     x_list3 <- dplyr::select(x_list, -one_of(names(x_list2)))
#
#     orig_df <- dplyr::select(spend_df[[i]], -one_of(names(x_list)))
#
#     spend_df[[i]] <- bind_rows(orig_df, y_list, x_list3)
#
# }
