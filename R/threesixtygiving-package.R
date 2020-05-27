
#' threesixtygiving package
#'
#' 360Giving is a data standard for publishing information about
#' charitable grant giving in the UK. `threesixtygiving` provides functions to
#' retrieve and process charitable grant funding data from 360Giving.
#'
#' @details See the [360 Giving website](https://www.threesixtygiving.org/)
#' for more information on the source of this data, and the
#' [360Giving Standard](https://standard.threesixtygiving.org) page for
#' details of the data standard this package relies on.
#'
#' @docType package
#' @name threesixtygiving
#' @importFrom jsonlite fromJSON
#' @importFrom readxl read_excel
#' @importFrom readr read_csv cols
#' @importFrom janitor clean_names remove_empty excel_numeric_to_date
#' @importFrom purrr map reduce
#' @importFrom dplyr vars select select_at mutate_all bind_rows inner_join
#' @importFrom tidyselect one_of everything all_of
#' @importFrom anytime anydate
#' @importFrom tibble as_tibble tibble
#' @importFrom tidyr unnest_wider
#' @importFrom httr RETRY write_disk timeout status_code http_status user_agent
#' @importFrom curl curl_download
#' @aliases NULL threesixtygiving-package
NULL
