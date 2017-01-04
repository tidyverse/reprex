context("input")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

test_that("clipboard input works", {
  skip_if_no_clipboard()
  clipr::write_clip("1:5")
  ret <- reprex(show = FALSE)
  expect_identical(ret, out)
})

test_that("expression input works", {
  ret <- reprex(1:5, show = FALSE)
  expect_identical(ret, out)
})

test_that("character input works", {
  ret <- reprex(input = "1:5\n", show = FALSE)
  expect_identical(ret, out)
})

test_that("file input works", {
  on.exit(file.remove("foo.R"))
  write("1:5", "foo.R")
  ret <- reprex(input = "foo.R", show = FALSE)
  expect_identical(ret, out)
})

test_that("Circular use is detected before render", {
  ret <- reprex(y <- 2, venue = "gh", show = FALSE)
  expect_error(reprex(input = ret, show = FALSE), "isn't valid R code")
  ret <- reprex(y <- 2, venue = "so", show = FALSE)
  expect_error(reprex(input = ret, show = FALSE), "isn't valid R code")
})

test_that("Leading prompts are removed", {
  input <- c("x <- 1:3", "median(x)")
  res <- reprex(input = input)
  input2 <- paste0(getOption("prompt"), input)
  expect_message(res2 <- reprex(input = input2), "Removing leading prompts")
  expect_identical(res, res2)
})
