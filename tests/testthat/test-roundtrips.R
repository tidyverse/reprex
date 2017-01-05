context("round trips")

input <- c(
  "## a comment",
  "x <- 1:4",
  "#' hi",
  "y <- 2:5",
  "x + y"
)

test_that("round trip: reprex(..., venue = 'R') --> reprex_clean()", {
  output <-
    reprex(input = input, show = FALSE, venue = "R",
           opts_chunk = list(comment = "#!"))
  expect_message(res <- reprex_clean(output, "^#!"))
  expect_identical(input, res[nzchar(res)])
})

test_that("round trip: reprex(..., venue = 'gh') --> reprex_invert()", {
  output <- reprex(input = input, show = FALSE)
  expect_message(res <- reprex_invert(output))
  expect_identical(input, res)
})

test_that("round trip: reprex(..., venue = 'so') --> reprex_invert()", {
  output <- reprex(input = input, venue = "so", show = FALSE)
  expect_message(res <- reprex_invert(output, venue = "so"))
  expect_identical(input, res)
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
