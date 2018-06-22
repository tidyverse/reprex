context("tidyverse")

test_that("reprex() suppresses tidyverse startup message by default", {
  skip_on_cran()
  skip_if_not_installed("tidyverse", minimum_version = "1.2.1")
  ret <- reprex(
    input = sprintf("library(%s)\n", "tidyverse"),
    show = FALSE, advertise = FALSE
  )
  expect_false(any(grepl("dplyr", ret)))
})

test_that("reprex() has control over tidyverse startup message", {
  skip_on_cran()
  skip_if_not_installed("tidyverse", minimum_version = "1.2.1")

  ret <- reprex(
    input = sprintf("library(%s)\n", "tidyverse"),
    tidyverse_quiet = TRUE,
    show = FALSE,
    advertise = FALSE
  )
  expect_false(any(grepl("dplyr", ret)))

  ret <- reprex(
    input = sprintf("library(%s)\n", "tidyverse"),
    tidyverse_quiet = FALSE,
    show = FALSE
  )
  expect_match(ret, "dplyr", all = FALSE)
})
