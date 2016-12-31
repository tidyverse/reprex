context("knitr options")

test_that("chunk options can be overridden", {
  src <- c(
    "(y <- 1:4)",
    "mean(y)"
  )
  short_form <-
    reprex(input = src, opts_chunk = list(collapse = FALSE), show = FALSE)
  header <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_chunk$set(collapse = FALSE)",
    "",
    "#+ actual-reprex-code"
  )
  long_form <- reprex(input = c(header, src), show = FALSE)
  expect_identical(short_form, long_form)
})

test_that("`comment` is special", {
  src <- c(
    "y <- 1:4",
    "mean(y)"
  )
  short_form <- reprex(input = src, comment = "#?#", show = FALSE)
  medium_form <-
    reprex(input = src, opts_chunk = list(comment = "#?#"), show = FALSE)
  header <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_chunk$set(comment = '#?#')",
    "",
    "#+ actual-reprex-code"
  )
  long_form <- reprex(input = c(header, src), show = FALSE)
  expect_identical(short_form, long_form)
  expect_identical(medium_form, long_form)
})
