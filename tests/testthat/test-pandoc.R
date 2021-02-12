test_that("pandoc does not add hard linebreak in the ad", {
  skip_on_cran()
  out <- reprex(input = "1:3\n", venue = "gh", advertise = TRUE)
  expect_match(out[length(out)], "Created on")
})
