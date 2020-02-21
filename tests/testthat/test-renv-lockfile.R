test_that("session info is omitted / included", {
  skip_on_cran()
  skip_if_not_installed("renv")

  regex <- "renv"
  input <- c("(y <- 1:4)", "mean(y)")
  ret <- reprex(input = input)
  expect_false(any(grepl(regex, ret)))
  ret <- reprex(input = input, renv_lockfile = TRUE)
  expect_match(ret, regex, all = FALSE)
})
