
#' Identify missing data sets
#'
#' Returns a tibble with details on any available data missing from a list
#' of grants returned by [tsg_all_grants()].
#'
#' @param x A list of tibble with grant data returned by [tsg_all_grants()].
#'
#' @return A tibble with details on funders missing data from a list of tibbles
#' passed to the function.
#' @export
#'
#' @examples
#' \dontrun{
#' all_grants <- tsg_all_grants()
#'
#' missing_grants <- tsg_missing(all_grants)
#' }
#'
tsg_missing <- function(x) {
  if (!is.list(x)) {
    stop("`x` must be a list of data frames with grant data.", call. = FALSE)
  }

  avail_df <- tsg_available()

  x2 <- unique(unlist(purrr::map(x, "dataset_id")))

  missing_df <- avail_df[!(avail_df$identifier %in% x2), ]

  missing_df
}






# tsg_download_missing <- function(x, data_dir = tempdir()) {
# ## Not working yet, need to complete to download missing data
#
#   g_list <- list()
#
#   for (i in seq_along(x$title)) {
#     if (verbose) {
#       message(paste0("Downloading ", i, " of ", length(x$title)))
#     }
#
#     suffix <- x$data_type[[i]]
#
#     result <- tryCatch( # Check availability
#       {
#         httr::RETRY("GET", x$download_url[[i]], httr::user_agent("Mozilla/5.0"),
#                     httr::write_disk(temp_f, overwrite = TRUE),
#                     times = retries,
#                     httr::timeout(timeout), terminate_on_success = FALSE
#         )
#       },
#       error = function(cond) {
#         return(NA)
#       }
#     )
#
#     g_list[[i]] <- result
#
#
#   # destfile <- file.path (data_dir, basename(x$download_url[[i]]))
#   #
#   # curl::curl_download(x$download_url[[i]], destfile)
#   #
#   #
#   # resp <- httr::GET (x$download_url[[i]],
#   #                    httr::write_disk (destfile, overwrite = TRUE))
#
#   }
#
# }
