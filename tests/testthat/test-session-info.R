context("session info")

test_that("session info is omitted / included", {
  if (requireNamespace("devtools", quietly = TRUE)) {
    regex <- "devtools::session_info()"
  } else {
    regex <- "sessionInfo()"
  }
  ret <- reprex({(y <- 1:4); mean(y)}, show = FALSE)
  expect_false(any(grepl(regex, ret)))
  ret <- reprex({(y <- 1:4); mean(y)}, si = TRUE, show = FALSE)
  expect_match(ret, regex, fixed = TRUE, all = FALSE)
  ret <- reprex({(y <- 1:4); mean(y)}, venue = "so", si = TRUE, show = FALSE)
  expect_match(ret, regex, fixed = TRUE, all = FALSE)
})

test_that("session info is folded on github", {
  ret <- reprex({(y <- 1:4); mean(y)}, show = FALSE, si = TRUE, venue = "gh")
  expect_match(ret, "<details><summary>Session info</summary>" ,
               fixed = TRUE, all = FALSE)
  expect_match(ret, "</details>", fixed = TRUE, all = FALSE)
})

