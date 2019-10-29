
#' threesixtygiving package
#'
#' Charity funding data for the UK. See the
#' [360 Giving website](https://www.threesixtygiving.org) for more information
#' on the source of this data.
#'
#' @docType package
#' @name threesixtygiving
#' @importFrom jsonlite fromJSON
#' @importFrom readxl read_excel
#' @importFrom readr read_csv cols
#' @importFrom curl curl_fetch_memory
#' @importFrom janitor clean_names remove_empty excel_numeric_to_date
#' @importFrom purrr map
#' @importFrom utils download.file
#' @importFrom dplyr vars select select_at mutate_all bind_rows filter case_when
#' @importFrom tidyselect one_of everything
#' @importFrom anytime anydate
#' @importFrom tibble as_tibble tibble
#' @importFrom tidyr unnest_wider
#' @importFrom stringr str_extract str_remove_all
#' @importFrom httr RETRY write_disk timeout status_code http_status
#' @aliases NULL threesixtygiving-package
NULL
