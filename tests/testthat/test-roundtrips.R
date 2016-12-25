context("round trips")

test_that("round trip with simple code works, invert md", {
  x <- reprex({
    ## a comment
    x <- 1:4
    #' hi
    y <- 2:5
    x + y
  }, show = FALSE)
  expect_output(res <- reprex_invert(x))
  expect_identical(res,
                   c("## a comment", "x <- 1:4", "#' hi", "y <- 2:5", "x + y"))
})

test_that("round trip with simple code works, clean text", {
  x <- c(
    "## a comment",
    "(x <- 1:4)",
    "#! [1] 1 2 3 4",
    "median(x)",
    "#! [1] 2.5"
  )
  expect_output(res <- reprex_clean(x, "^#!"))
  expect_identical(res, c("## a comment", "(x <- 1:4)", "median(x)"))
})
