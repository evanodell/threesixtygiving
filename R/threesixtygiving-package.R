
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
#' @import tidyr
#' @import httr
#' @importFrom dplyr as_tibble one_of vars select select_at mutate_all bind_rows filter everything tibble case_when
#' @aliases NULL threesixtygiving-package
NULL
