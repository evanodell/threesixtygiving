
#' Process to tibble
#'
#' Given a list returned by [tsg_all_grants()] or [tsg_search_grants()], creates
#' a tibble with all available variables. All variables are converted to
#' character class. This tibble contains roughly 200 columns if all available
#' grants are used (as of October 2019), due to differences in labelling and
#' structuring grant data.
#'
#' @seealso tsg_core_data
#'
#' @inheritParams tsg_core_data
#'
#' @return A tibble with all variables from all grants
#' @export
#'
#' @examples
#' \donttest{
#' grants <- tsg_all_grants()
#'
#' df <- tsg_process_data(grants)
#' }
#'
tsg_process_data <- function(x, verbose = TRUE) {
  for (i in seq_along(x)) {
    if (any(x[[i]][["data_type"]] == "json")) {
      x[[i]] <- tidyr::unnest_wider(x[[i]], "funding_organization",
        names_sep = "_"
      )
      x[[i]] <- tidyr::unnest_wider(x[[i]], "recipient_organization",
        names_sep = "_"
      )

      if ("recipient_organization_location" %in% colnames(x[[i]])) {
        x[[i]][["recipient_organization_location"]] <- purrr::flatten(
          x[[i]][["recipient_organization_location"]]
        )
        x[[i]] <- tidyr::unnest_wider(x[[i]], "recipient_organization_location",
          names_sep = "_"
        )
      }

      if ("funding_organization_location" %in% colnames(x[[i]])) {
        x[[i]][["funding_organization_location"]] <- purrr::flatten(
          x[[i]][["funding_organization_location"]]
        )
        x[[i]] <- tidyr::unnest_wider(x[[i]], "funding_organization_location",
          names_sep = "_"
        )
      }

      if ("planned_dates" %in% colnames(x[[i]])) {
        x[[i]] <- tidyr::unnest_wider(x[[i]], "planned_dates", names_sep = "_")
      }

      if ("grant_programme" %in% colnames(x[[i]])) {
        x[[i]] <- tidyr::unnest_wider(x[[i]], "grant_programme",
          names_sep = "_"
        )
      }

      if ("beneficiary_location" %in% colnames(x[[i]])) {
        x[[i]] <- tidyr::unnest_wider(x[[i]], "beneficiary_location",
          names_sep = "_"
        )
      }

      if ("classifications" %in% colnames(x[[i]])) {
        x[[i]] <- tidyr::unnest_wider(x[[i]], "classifications",
          names_sep = "_"
        )

        if ("classifications_code" %in% colnames(x[[i]])) {
          x[[i]][["classifications_code"]] <- unlist(lapply(
            x[[i]][["classifications_code"]], paste,
            collapse = ", "
          ))
        }

        if ("classifications_title" %in% colnames(x[[i]])) {
          x[[i]][["classifications_title"]] <- unlist(lapply(
            x[[i]][["classifications_title"]], paste,
            collapse = ", "
          ))
        }

        if ("classifications_url" %in% colnames(x[[i]])) {
          x[[i]][["classifications_url"]] <- unlist(lapply(
            x[[i]][["classifications_url"]], paste,
            collapse = ", "
          ))
        }

        if ("classifications_vocabulary" %in% colnames(x[[i]])) {
          x[[i]][["classifications_vocabulary"]] <- unlist(lapply(
            x[[i]][["classifications_vocabulary"]], paste,
            collapse = ", "
          ))
        }
      }

      x[[i]] <- janitor::clean_names(x[[i]])
      x[[i]] <- janitor::remove_empty(x[[i]], which = "cols")

      names(x[[i]]) <- gsub("organization", "org", names(x[[i]]))
      names(x[[i]]) <- gsub("org_id$", "org_identifier", names(x[[i]]))
    }
    if (verbose) message(paste0("Processing ", i, " of ", length(x)))
  }

  x <- lapply(x, dplyr::mutate_all, as.character)
  df <- dplyr::bind_rows(x)

  df <- dplyr::filter(df, !is.na(identifier))

  df
}
