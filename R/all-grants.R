


#' All grants
#'
#' Returns a list of data frames with details of all grants from funders
#' returned by [tsg_available()].
#'
#' @param core_data If `TRUE`
#' @param verbose If `TRUE`, prints console messages.
#'
#' @return A list of data frames.
#' @export
#'
#' @examples \donttest{
#' all_grants <- tsg_all_grants()
#' }


tsg_all_grants <- function(core_data = FALSE, verbose = TRUE) {
  grant_df <- tsg_available()

  df <- tsg_data_retrieval(grant_df, verbose = verbose)

   if (core_data) {
      # get all the common spending information into a single dataset
   }
  df
}
# attempts to sort out this whole nested data frame problem
# library(dplyr)
# x <- as_tibble(unlist(lapply(df, names)))
#
#
# x2 <- x %>% group_by(value) %>% summarise(n=n()) %>% arrange(desc(n))
#
# x2
#
# df2 <- df
# for (i in 1:216) {
#
# df2[[i]][, ] <- lapply(df2[[i]][, ], as.character)
#
# }
#
# df2 <- bind_rows(df2) ## check what is missing common names
#
# df_bind <- bind_rows(df)
#
# df_missing <- df2 %>% filter(is.na(recipient_org_identifier))
#
# summary(factor(df_missing$id2))
#
# df_missing2 <- df_missing[,colSums(is.na(df_missing))<nrow(df_missing)]
#
# unique(df_missing2$id2)
#
# t2 <- df[[38]]
#
# t1 %>% unnest(recipient_organization)
#
# x <- bind_rows(t1$recipient_organization)
#
# t2xx <- t2  %>%
#   mutate_if(is.list, bind_rows)
#
#
# ss <- t2 %>% mutate(Value = map(recipient_organization, rownames_to_column, "a"))
#
# ss$Value
#
# df1 <- tibble(
#   gr = c('a', 'b', 'c'),
#   values = list(1:2, 3:4, 5:6)
# )
#
#
# t2 %>% map_df(recipient_organization, as_tibble)
#
# df1 %>%
#   mutate(r = map(., ~ data.frame(t(.)))) %>%
#   unnest(r) %>%
#   select(-values)
#
#
# library(tidyverse)
#
# df6 %>%
#   mutate(Value = map(Value, as.data.frame),
#          Value = map(Value, rownames_to_column, 'a'),
#          Value = map(Value, ~gather(., b, value, -a))) %>%
#   unnest(Value) %>%
#   complete(Step, a, b)
