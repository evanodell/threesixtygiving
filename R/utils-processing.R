
# Utility function to process list to a tibble
#
# @param x the list to process
# @param verbose Verbose option
# @param process_type if `"core"`, only processes core stuff

tsg_core_process <- function(x, verbose, process_type) {
  if (is.data.frame(x)) {
    x <- list(x)
  }

  ## need to somehow deal with the missing tibbles

  if (process_type == "core") {
    for (i in seq_along(x)) {
      req2 <- tsg_proc_req_list[tsg_proc_req_list %in% colnames(x[[i]])]

      if (length(req2) >= 1) {
        x[[i]] <- dplyr::select_at(x[[i]], dplyr::vars(tidyselect::one_of(req2)))
      } else {
        x[[i]] <- NA
      }
    }
  }

  for (i in seq_along(x)) {
    if (all(is.na(x[[i]]))) {
    } else {
      if (any(x[[i]][["data_type"]] == "json")) {
        x[[i]] <- tidyr::unnest_wider(x[[i]], "funding_organization",
          names_sep = "_"
        )
        x[[i]] <- tidyr::unnest_wider(x[[i]], "recipient_organization",
          names_sep = "_"
        )

        if (process_type == "all") { ## to avoid a bunch of needless code running

          if ("recipient_organization_location" %in% colnames(x[[i]])) {

            x[[i]][["recipient_organization_location"]][
              sapply( x[[i]][["recipient_organization_location"]], is.null)
              ] <- NA

            x[[i]][["recipient_organization_location"]] <- purrr::flatten(
              x[[i]][["recipient_organization_location"]]
            )

            x[[i]][["recipient_organization_location"]] <- lapply(
              x[[i]][["recipient_organization_location"]],
              tibble::as_tibble
            )

            x[[i]] <- tidyr::unnest_wider(x[[i]],
              "recipient_organization_location",
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
            x[[i]] <- tidyr::unnest_wider(x[[i]],
              "planned_dates",
              names_sep = "_"
            )
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
        }

        x[[i]] <- janitor::clean_names(x[[i]])
        x[[i]] <- janitor::remove_empty(x[[i]], which = "cols")

        names(x[[i]]) <- gsub("organization", "org", names(x[[i]]))
        names(x[[i]]) <- gsub("org_id$", "org_identifier", names(x[[i]]))
      }

      if (process_type == "core") {
        req3 <- tsg_req_list[tsg_req_list %in% colnames(x[[i]])]

        x[[i]] <- dplyr::select_at(
          x[[i]],
          dplyr::vars(tidyselect::one_of(req3))
        )
      }
    }
    if (verbose) message(paste0("Processing ", i, " of ", length(x)))
  }

  x <- lapply(x, dplyr::mutate_all, as.character)
  df <- dplyr::bind_rows(x)

  df <- dplyr::select(
    df, tidyselect::all_of(tsg_req_list),
    tidyselect::everything()
  )

  df$amount_awarded <- as.numeric(df$amount_awarded)
  df$award_date <- as.Date(df$award_date)

  df
}
