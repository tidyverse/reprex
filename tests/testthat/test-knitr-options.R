context("knitr options")

test_that("chunk options can be overridden", {
  src <- c(
    "y <- 1:4",
    "mean(y)"
  )
  short_form <-
    reprex(src = src, opts_chunk = list(comment = "#?#"), show = FALSE)
  header <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_chunk$set(comment = '#?#')",
    "",
    "#+ actual-reprex-code"
  )
  long_form <- reprex(src = c(header, src), show = FALSE)
  expect_identical(short_form, long_form)
})
