
## excel reading function utility to reduce code reproduction

tsg_json <- function(temp_f) {
  z <- tryCatch(
    {
      jsonlite::fromJSON(temp_f,
        flatten = FALSE
      )
    },
    error = function(cond) {
      return(NA)
    }
  )

  ## due to `grants` being nested one level down
  if (!is.data.frame(z) && is.data.frame(z[[1]])) {
    z <- tibble::as_tibble(z[[1]])
  }

  z
}
