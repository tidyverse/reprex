context("tidyverse")

test_that("reprex() suppresses tidyverse startup message by default", {
  skip_if_not_installed("tidyverse", minimum_version = "1.1.1.9000")
  ret <- reprex(input = "library(tidyverse)\n", show = FALSE, advertise = FALSE)
  expect_false(any(grepl("#>", ret)))
})

test_that("reprex() has control over tidyverse startup message", {
  skip_if_not_installed("tidyverse", minimum_version = "1.1.1.9000")

  ret <- reprex(
    input = "library(tidyverse)\n",
    tidyverse_quiet = TRUE,
    show = FALSE,
    advertise = FALSE
  )
  expect_false(any(grepl("#>", ret)))

  ret <- reprex(
    input = "library(tidyverse)\n",
    tidyverse_quiet = FALSE,
    show = FALSE
  )
  expect_true(any(grepl("#>", ret)))
})
