
#' Core Data
#'
#' Given a list returned by [tsg_all_grants()] or [tsg_search_grants()], creates
#' a tibble with the core variables required by the
#' [360Giving](https://standard.threesixtygiving.org/en/latest/) open standard,
#' as well as the publisher prefix which is useful for data processing.
#'
#' @param x A list of tibble with grant data returned by [tsg_all_grants()].
#' @inheritParams tsg_all_grants
#'
#' @return A tibble with core variables
#' @export
#'
#' @examples
#' \donttest{
#' grants <- tsg_all_grants()
#'
#' df <- tsg_core_data(grants)
#' }
tsg_core_data <- function(x, verbose = TRUE) {
  req_list <- c(
    "identifier", "title", "description", "currency",
    "amount_awarded", "award_date", "recipient_org_identifier",
    "recipient_org_name", "funding_org_identifier",
    "funding_org_name", "recipient_org", "funding_org",
    "recipient_organization", "funding_organization",
    "publisher_prefix", "counter", "suffix", "data_type"
  )

  y2 <- list()

  for (i in seq_along(x)) {
    y2[[i]] <- dplyr::select_at(x[[i]], dplyr::vars(dplyr::one_of(req_list)))
  }

  for (i in seq_along(y2)) {
    if (any(y2[[i]][["data_type"]] == "json")) {
      y2[[i]] <- tidyr::unnest_wider(y2[[i]], "funding_organization",
                                     names_sep = "_")
      y2[[i]] <- tidyr::unnest_wider(y2[[i]], "recipient_organization",
                                     names_sep = "_")

      y2[[i]] <- janitor::clean_names(y2[[i]])
      names(y2[[i]]) <- gsub("organization", "org", names(y2[[i]]))
      names(y2[[i]]) <- gsub("org_id$", "org_identifier", names(y2[[i]]))

      y2[[i]] <- dplyr::select_at(y2[[i]], dplyr::vars(dplyr::one_of(req_list)))
    }

    if (verbose) message(paste0("Processing ", i, " of ", length(y2)))
  }

  y2 <- lapply(y2, dplyr::mutate_all, as.character)

  df <- dplyr::bind_rows(y2)

  #df <- dplyr::filter(df, !is.na(identifier))

  df$data_type <- NULL

  df$amount_awarded <- as.numeric(df$amount_awarded)

  df
}
