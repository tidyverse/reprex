context("knitr options")

test_that("chunk options can be overridden", {
  skip_on_cran()
  src <- c(
    "(y <- 1:4)",
    "mean(y)"
  )
  short_form <-
    reprex(
      input = src,
      opts_chunk = list(collapse = FALSE),
      show = FALSE,
      advertise = FALSE
    )
  header <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_chunk$set(collapse = FALSE)",
    "",
    "#+ actual-reprex-code"
  )
  long_form <- reprex(input = c(header, src), show = FALSE, advertise = FALSE)
  expect_identical(short_form, long_form)
})

test_that("`comment` is special", {
  skip_on_cran()
  src <- c(
    "y <- 1:4",
    "mean(y)"
  )
  short_form <- reprex(
    input = src,
    comment = "#?#",
    show = FALSE,
    advertise = FALSE
  )
  medium_form <-
    reprex(
      input = src,
      opts_chunk = list(comment = "#?#"),
      show = FALSE,
      advertise = FALSE
    )
  header <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_chunk$set(comment = '#?#')",
    "",
    "#+ actual-reprex-code"
  )
  long_form <- reprex(input = c(header, src), show = FALSE, advertise = FALSE)
  expect_identical(short_form, long_form)
  expect_identical(medium_form, long_form)
})

test_that("venue determines default value of `upload.fun`", {
  skip_on_cran()
  out <- reprex(plot(1), render = FALSE)
  expect_match(out, "knitr::imgur_upload", all = FALSE)
  out <- reprex(plot(1), render = FALSE, venue = "r")
  expect_match(out, "identity", all = FALSE)
})
