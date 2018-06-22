context("optionally")

test_that("`si` can be set via option", {
  skip_on_cran()
  withr::with_options(
    list(reprex.si = TRUE),
    out <- reprex(1, render = FALSE)
  )
  expect_match(out, "session_*[iI]nfo", all = FALSE)
})

test_that("`advertise` can be set via option", {
  skip_on_cran()
  withr::with_options(
    list(reprex.advertise = FALSE),
    out <- reprex(1, render = FALSE)
  )
  expect_false(any(grepl("#+ reprex-ad", out, fixed = TRUE)))
})

test_that("`comment` can be set via option", {
  skip_on_cran()
  withr::with_options(
    list(reprex.comment = "#? "),
    out <- reprex(rnorm(1), show = FALSE)
  )
  expect_match(out, "^#\\?", all = FALSE)
})

test_that("`tidyverse_quiet` can be set via option", {
  skip_on_cran()
  withr::with_options(
    list(reprex.tidyverse_quiet = FALSE),
    out <- reprex(mean(1:3), render = FALSE)
  )
  expect_match(out, "tidyverse.quiet = FALSE", fixed = TRUE, all = FALSE)
})

test_that("`std_out_err` can be set via option", {
  skip_on_cran()
  withr::with_options(
    list(reprex.std_out_err = TRUE),
    out <- reprex(1, render = FALSE)
  )
  expect_match(out, "std_out_err", all = FALSE)
})
