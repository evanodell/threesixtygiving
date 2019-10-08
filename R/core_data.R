
#' Title
#'
#' @param grant_data A list returned from [tsg_all_grants()].
#'
#' @return
#' @export
#'
#' @examples
#'

tsg_core_data <- function(grant_data) {

  x <- dplyr::bind_rows(grant_data)

  df <- lapply(df, tidyr::unnest)

}
