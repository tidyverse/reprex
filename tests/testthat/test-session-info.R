context("session info")

test_that("session info is omitted / included", {
  skip_on_cran()
  if (rlang::is_installed("sessioninfo")) {
    regex <- "^sessioninfo::session_info"
  } else {
    regex <- "^sessionInfo"
  }
  input <- c("(y <- 1:4)", "mean(y)")
  ret <- reprex(input = input, render = FALSE)
  expect_false(any(grepl(regex, ret)))
  ret <- reprex(input = input, si = TRUE, render = FALSE)
  expect_match(ret, regex, all = FALSE)
})

test_that("session info is folded on github", {
  skip_on_cran()
  input <- c("(y <- 1:4)", "mean(y)")
  ret <- reprex(input = input, render = FALSE, si = TRUE, venue = "gh")
  expect_match(
    ret, "<details><summary>Session info</summary>",
    fixed = TRUE, all = FALSE
  )
  expect_match(ret, "</details>", fixed = TRUE, all = FALSE)
})
