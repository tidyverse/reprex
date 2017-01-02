context("venues")

test_that("venue = 'so' works", {
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "<!-- language-all: lang-r -->",
    "<br/>",
    "",
    "Hello world",
    "",
    "    ## comment",
    "    1:5",
    "    #> [1] 1 2 3 4 5"
  )
  ret <- reprex(input = input, venue = "so", show = FALSE)
  expect_identical(ret, output)
})

test_that("venue = 'R' works", {
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "#' Hello world",
    "## comment",
    "1:5",
    "#> [1] 1 2 3 4 5"
  )
  ret <- reprex(input = input, venue = "R", show = FALSE)
  expect_identical(ret[nzchar(ret)], output)
  ret <- reprex(input = input, venue = "r", show = FALSE)
  expect_identical(ret[nzchar(ret)], output)
})
