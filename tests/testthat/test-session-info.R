context("session info")

test_that("session info added, github", {
  if (requireNamespace("devtools", quietly = TRUE)) {
    regex <- "<details><summary>`devtools::session_info()`</summary>"
  } else {
    regex <- "sessionInfo()"
  }
  ret <- reprex({(y <- 1:4); mean(y)}, si = TRUE, show = FALSE)
  expect_match(ret, regex, fixed = TRUE, all = FALSE)
})

test_that("session info added, stackoverflow", {
  if (requireNamespace("devtools", quietly = TRUE)) {
    regex <- "devtools::session_info()"
  } else {
    regex <- "sessionInfo()"
  }
  ret <- reprex({(y <- 1:4); mean(y)}, venue = "so", si = TRUE, show = FALSE)
  expect_match(ret, regex, fixed = TRUE, all = FALSE)
})
