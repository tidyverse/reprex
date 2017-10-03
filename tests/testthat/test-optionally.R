context("optionally")

test_that("si can be set via option", {
  withr::with_options(
    list(si = TRUE),
    out <- reprex(1, render = FALSE)
  )
  expect_match(out, "session_*[iI]nfo", all = FALSE)
})

test_that("comment can be set via option", {
  withr::with_options(
    list(comment = "#? "),
    out <- reprex(rnorm(1), show = FALSE)
  )
  expect_match(out, "^#\\?", all = FALSE)
})

test_that("tidyverse_quiet can be set via option", {
  withr::with_options(
    list(tidyverse_quiet = FALSE),
    out <- reprex(library(tidyverse), render = FALSE)
  )
  expect_match(out, "tidyverse.quiet = FALSE", fixed = TRUE, all = FALSE)
})

test_that("std_out_err can be set via option", {
  withr::with_options(
    list(std_out_err = TRUE),
    out <- reprex(1, render = FALSE)
  )
  expect_match(out, "standard output and standard error", all = FALSE)
})
