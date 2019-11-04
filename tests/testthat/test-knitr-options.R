test_that("`comment` works", {
  skip_on_cran()
  src <- c(
    "y <- 1:4",
    "mean(y)"
  )
  arg_form <- reprex(
    input = src,
    comment = "#?#",
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
  expect_identical(arg_form, long_form)
})
