
#' threesixtygiving package
#'
#' Charity funding data for the UK. See the
#' [360 Giving website](https://www.threesixtygiving.org) for more information
#' on the source of this data.
#'
#' @docType package
#' @name threesixtygiving
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr inner_join bind_rows as_tibble mutate_if filter
#' @importFrom readxl read_excel
#' @importFrom readr read_csv cols
#' @importFrom curl curl_fetch_memory
#' @importFrom janitor clean_names remove_empty
#' @importFrom purrr map
#' @importFrom utils download.file
#' @import tidyr
#' @import httr
#' @aliases NULL threesixtygiving-package
NULL
