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
  ret <- reprex(src = input, venue = "so", show = FALSE)
  expect_identical(ret, output)
})
