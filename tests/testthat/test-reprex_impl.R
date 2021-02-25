# https://github.com/tidyverse/reprex/issues/363
# ironically, reprex.advertise = FALSE + reprex(advertise = FALSE)
# resulted in reprex(advertise = TRUE) behaviour
test_that("reprex.advertise default detection isn't affected by the option", {
  full_list   <- list(advertise = FALSE, venue = "gh", session_info = FALSE)
  non_default <- list(advertise = FALSE)

  withr::with_options(
    list(reprex.advertise = TRUE),
    expect_equal(remove_defaults(full_list), non_default)
  )
  withr::with_options(
    list(reprex.advertise = FALSE),
    expect_equal(remove_defaults(full_list), non_default)
  )
  withr::with_options(
    list(reprex.advertise = NULL),
    expect_equal(remove_defaults(full_list), non_default)
  )
})
