context("knitr options")

test_that("chunk options can be overridden", {
  short_form <- reprex({
    y <- 1:4
    mean(y)
  }, opts_chunk = list(comment = "#?#"))
  long_form <- reprex({
    #+ setup, include = FALSE
    knitr::opts_chunk$set(comment = '#?#')

    #+ actual-reprex-code
    y <- 1:4
    mean(y)
  })
  expect_identical(short_form, long_form)
})
