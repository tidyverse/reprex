context("round trips")

test_that("round trip with simple code works, clean text", {
  input <- c(
    "## a comment",
    "(x <- 1:4)",
    "median(x)"
  )
  output <-
    reprex(input = input, show = FALSE, opts_chunk = list(comment = "#!"))
  output <- output[!grepl("^```", output)]
  expect_output(res <- reprex_clean(output, "^#!"))
  expect_identical(res, input)
})

test_that("round trip with simple code works, invert md, venue gh", {
  input <- c(
    "## a comment",
    "x <- 1:4",
    "#' hi",
    "y <- 2:5",
    "x + y"
  )
  output <- reprex(input = input, show = FALSE)
  expect_output(res <- reprex_invert(output))
  expect_identical(input, res)
})

test_that("round trip with simple code works, invert md, venue so", {
  input <- c(
    "## a comment",
    "x <- 1:4",
    "#' hi",
    "y <- 2:5",
    "x + y"
  )
  output <- reprex(input = input, venue = "so", show = FALSE)
  expect_output(res <- reprex_invert(output, venue = "so"))
  expect_identical(input, res)
})

test_that("round trip with simple code works, clean .R, venue r", {
  input <- c(
    "## a comment",
    "x <- 1:4",
    "#' hi",
    "y <- 2:5",
    "x + y"
  )
  output <- reprex(input = input, venue = "R", show = FALSE)
  expect_output(res <- reprex_clean(output))
  expect_identical(input, res)
})
