

# need to complete this function

#' Core Data
#'
#' Given a list returned by [tsg_all_grants()] or [tsg_search_grants()], creates
#' a tibble with the core variables required by the
#' [360Giving](https://standard.threesixtygiving.org/en/latest/) open standard.
#'
#' @param x A list of tibble with grant data returned by [tsg_all_grants()].
#'
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
tsg_core_data <- function(x) {

  req_list <- snakecase::to_snake_case(
    c("Identifier", "Title", "Description", "Currency", "Amount Awarded",
      "Award Date", "Recipient Org:Identifier", "Recipient Org:Name",
      "Funding Org:Identifier", "Funding Org:Name", "Recipient Org",
      "Funding Org", "recipient_organization","funding_organization",
      "publisher_prefix", "counter", "suffix", "data_type"))

  req_list2 <- snakecase::to_snake_case(
    c("Identifier", "Title", "Description", "Currency", "Amount Awarded",
      "Award Date", "Recipient Org:Identifier", "Recipient Org:Name",
      "Funding Org:Identifier", "Funding Org:Name"))


  y2 <- list()

  for (i in seq_along(x)) {

    y2[[i]] <- select_at(x[[i]], vars(one_of(req_list)))

  }

  for (i in seq_along(y2)) {

    if (any(y2[[i]][["data_type"]] == "json")) {

      y2[[i]] <- unnest_wider(y2[[i]], "funding_organization", names_sep = "_")
      y2[[i]] <- unnest_wider(y2[[i]], "recipient_organization", names_sep = "_")

      y2[[i]] <- janitor::clean_names(y2[[i]])
      names(y2[[i]]) <- gsub("organization", "org", names(y2[[i]]))
      names(y2[[i]]) <- gsub("org_id$", "org_identifier", names(y2[[i]]))

      y2[[i]] <- select_at(y2[[i]], vars(one_of(req_list)))

    }

    message(paste0("Processing ", i, " of ", length(y2)))

  }

  y2 <- lapply(y2, dplyr::mutate_all, as.character)

  df <- dplyr::bind_rows(y2)

  df <- dplyr::filter(df, !is.na(identifier))

  df$data_type <- NULL

  df
}
