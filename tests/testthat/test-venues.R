context("venues")

test_that("venue = 'so' works with/without leading prose", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "<!-- language-all: lang-r -->",
    "Hello world",
    "",
    "    ## comment",
    "    1:5",
    "    #> [1] 1 2 3 4 5"
  )
  ret <- reprex(input = input, venue = "so", show = FALSE, advertise = FALSE)
  expect_identical(ret, output)

  input <- grep("Hello", input, invert = TRUE, value = TRUE)
  output <- grep("Hello", output, invert = TRUE, value = TRUE)
  ret <- reprex(input = input, venue = "so", show = FALSE, advertise = FALSE)
  expect_identical(ret, output)
})

test_that("venue = 'R' works, regardless of case", {
  skip_on_cran()
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
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  ds <- reprex(input = input, venue = "ds", si = TRUE, show = FALSE, advertise = FALSE)
  gh <- reprex(input = input, venue = "gh", si = TRUE, show = FALSE, advertise = FALSE)
  expect_identical(ds, gh)
})

test_that("local image link is not interrupted by hard line break for 'gh'", {
  skip_on_cran()
  input <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_knit$set(upload.fun = identity)",
    "",
    "#+ incredibly-long-chunk-name-to-make-image-path-also-incredibly-long",
    "plot(1:3)"
  )
  out <- reprex(input = input, venue = "gh", show = FALSE)
  i <- grep("incredibly-long", out)
  expect_true(grepl("[)]", out[i]))
})
