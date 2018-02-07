context("pandoc")

test_that("pandoc does not add hard linebreak in the ad", {
  out <- reprex(input = "1:3\n", venue = "gh", show = FALSE, advertise = TRUE)
  expect_match(out[length(out)], "^Created on")
  out <- reprex(input = "1:3\n", venue = "so", show = FALSE, advertise = TRUE)
  expect_match(out[length(out)], "^Created on")
})

test_that("pandoc version checkers don't error", {
  expect_error_free(pandoc2.0())
})
