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
  expect_message(res <- reprex_clean(output, "^#!"))
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
  expect_message(res <- reprex_invert(output))
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
  expect_message(res <- reprex_invert(output, venue = "so"))
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
  expect_message(res <- reprex_clean(output))
  expect_identical(input, res[nzchar(res)])
})

test_that("code can be rescued from R Console copy/paste", {
  input <- c(
    "> ## a regular comment, which is retained",
    "> (x <- 1:4)",
    "[1] 1 2 3 4",
    "> median(x)",
    "[1] 2.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(x <- 1:4)",
    "median(x)"
  )
  expect_message(res <- reprex_rescue(input))
  expect_identical(res, output)
})

test_that("prompt argument works", {
  input <- c(
    ":-) ## a regular comment, which is retained",
    ":-) (x <- 1:4)",
    "[1] 1 2 3 4",
    ":-) median(x)",
    "[1] 2.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(x <- 1:4)",
    "median(x)"
  )
  expect_message(res <- reprex_rescue(input, prompt = ":-) "))
  expect_identical(res, output)
})
