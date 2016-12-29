context("input")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

test_that("clipboard input works", {
  skip_if_no_clipboard()
  clipr::write_clip("1:5")
  ret <- reprex(show = FALSE)
  expect_identical(ret, out)
})

test_that("expression input works", {
  ret <- reprex(1:5, show = FALSE)
  expect_identical(ret, out)
})

test_that("character input works", {
  ret <- reprex(input = "1:5\n", show = FALSE)
  expect_identical(ret, out)
})

test_that("file input works", {
  on.exit(file.remove("foo.R"))
  write("1:5", "foo.R")
  ret <- reprex(input = "foo.R", show = FALSE)
  expect_identical(ret, out)
})

test_that("Circular use is detected before render", {
  on.exit(file.remove(c("foo.R", "foo.md")))
  ret <- reprex(y <- 2, outfile = "foo", show = FALSE)
  expect_error(reprex(input = "foo.md", show = FALSE), "isn't valid R code")
})
