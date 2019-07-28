# probe a system for which two-letter language codes can be used in the
# LANGUAGE env var to influence the language used for messages

library(tidyverse)
library(withr)

#x <- read_csv(here::here("internal/language-codes.csv"), comment = "#")
x <- read_csv("https://datahub.io/core/language-codes/r/language-codes.csv")

oops <- function() tryCatch("a"/1, error = function(e) e)$message
probe_language <- function(l) with_envvar(c(LANGUAGE = l), oops())

x <- x %>%
  mutate(
    error = map_chr(alpha2, probe_language),
    english = error == probe_language("en")
  )

x %>%
  filter(!english)
