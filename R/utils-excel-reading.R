
## excel reading function utility to reduce code reproduction
tsg_excel <- function(temp_f) {
  z <- tryCatch(
    { ## majority of returns
      if ("#Awards data" %in% readxl::excel_sheets(temp_f)) {
        s <- readxl::read_excel(temp_f, sheet = "#Awards data")
      } else if (length(readxl::excel_sheets(temp_f)) > 1) {
        multi <- lapply(readxl::excel_sheets(temp_f),
          readxl::read_excel,
          path = temp_f,
          guess_max = 21474836
        )

        s_rows <- nrow(multi[[1]])

        s_list <- list()
        for (k in seq_along(multi)) {
          if (nrow(multi[[k]]) == s_rows) {
            s_list[[k]] <- multi[[k]]
          }
        }
        s_list[sapply(s_list, is.null)] <- NULL

        s <- purrr::reduce(s_list, dplyr::inner_join)
      } else {
        s <- readxl::read_excel(temp_f, guess_max = 21474836)
      }

      s
    },
    error = function(cond) {
      return(NA)
    }
  )

  z
}
