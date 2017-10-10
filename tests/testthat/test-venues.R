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
  ret <- reprex(input = input, venue = "so", show = FALSE, advertise = FALSE)
  expect_identical(ret, output)
})

test_that("venue = 'R' works, regardless of case", {
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
  ret <- reprex(input = input, venue = "R", show = FALSE, advertise = FALSE)
  expect_identical(ret[nzchar(ret)], output)
  ret <- reprex(input = input, venue = "r", show = FALSE, advertise = FALSE)
  expect_identical(ret[nzchar(ret)], output)
})

test_that("venue = 'ds' is an alias for 'gh'", {
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  ds <- reprex(input = input, venue = "ds", si = TRUE, show = FALSE, advertise = FALSE)
  gh <- reprex(input = input, venue = "gh", si = TRUE, show = FALSE, advertise = FALSE)
  expect_identical(ds, gh)
})
