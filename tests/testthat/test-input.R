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
  ret <- reprex(src = "1:5", show = FALSE)
  expect_identical(ret, out)
})

test_that("file input works", {
  on.exit(file.remove("foo.R"))
  write("1:5", "foo.R")
  ret <- reprex(infile = "foo.R", show = FALSE)
  expect_identical(ret, out)
})

test_that("Circular use is detected before render", {
  on.exit(file.remove("foo.md"))
  ret <- reprex(y <- 2, show = FALSE)
  write(ret, "foo.md")
  expect_error(reprex(infile = "foo.md", show = FALSE), "isn't valid R code")
})
