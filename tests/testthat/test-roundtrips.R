context("round trips")

input <- c(
  "## a comment",
  "x <- 1:4",
  "#' hi",
  "y <- c(2,",
  "       3, 4,",
  "       5)",
  "x + y"
)

test_that("round trip: reprex(..., venue = 'R') --> reprex_clean()", {
  output <- reprex(
    input = input,
    advertise = FALSE,
    show = FALSE,
    venue = "r",
    opts_chunk = list(comment = "#!")
  )
  expect_message(res <- reprex_clean(output, "^#!"))
  expect_identical(input, res[nzchar(res)])
})

test_that("round trip: reprex(..., venue = 'gh') --> reprex_invert()", {
  output <- reprex(input = input, show = FALSE, advertise = FALSE)
  expect_message(res <- reprex_invert(output))
  ## TO DO: return here after adopting styler to see if can remove trim_ws()
  expect_identical(trim_ws(input), trim_ws(res))
})

test_that("round trip: reprex(..., venue = 'so') --> reprex_invert()", {
  output <- reprex(input = input, venue = "so", show = FALSE, advertise = FALSE)
  expect_message(res <- reprex_invert(output, venue = "so"))
  expect_identical(input, res)
})

test_that("code can be rescued from R Console copy/paste", {
  input <- c(
    "> ## a regular comment, which is retained",
    "> (y <- c(2,",
    "+         3, 4,",
    "+         5))",
    "[1] 2 3 4 5",
    "> median(y)",
    "[1] 3.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(y <- c(2,",
    "        3, 4,",
    "        5))",
    "median(y)"
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

test_that("continue argument works", {
  input <- c(
    "> ## a regular comment, which is retained",
    "> (y <- c(2,",
    "yes, and?         3, 4,",
    "yes, and?         5))",
    "[1] 2 3 4 5",
    "> median(y)",
    "[1] 3.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(y <- c(2,",
    "        3, 4,",
    "        5))",
    "median(y)"
  )
  expect_message(res <- reprex_rescue(input, continue = "yes, and? "))
  expect_identical(res, output)
})

test_that("rescue can cope with leading whitespace",{
  input <- c(
    "> ## a regular comment, which is retained",
    " > (x <- 1:4)",
    "   [1] 1 2 3 4",
    "   > median(x)",
    "2.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(x <- 1:4)",
    "median(x)"
  )
  expect_message(res <- reprex_rescue(input))
  expect_identical(res, output)
})
