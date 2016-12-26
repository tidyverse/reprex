context("round trips")

test_that("round trip with simple code works, invert md", {
  input <- c(
    "## a comment",
    "x <- 1:4",
    "#' hi",
    "y <- 2:5",
    "x + y"
  )
  output <- reprex(src = input, show = FALSE)
  expect_output(res <- reprex_invert(output))
  expect_identical(input, res)
})

test_that("round trip with simple code works, clean text", {
  input <- c(
    "## a comment",
    "(x <- 1:4)",
    "median(x)"
  )
  output <- reprex(src = input, show = FALSE, opts_chunk = list(comment = "#!"))
  output <- output[!grepl("^```", output)]
  expect_output(res <- reprex_clean(output, "^#!"))
  expect_identical(res, input)
})
