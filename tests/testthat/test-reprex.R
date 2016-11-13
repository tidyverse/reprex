context("reprex")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

test_that("clipboard input works", {
  clipr::write_clip("1:5")
  ret <- reprex(show = FALSE)
  expect_identical(ret, out)
})

test_that("expression input works", {
  ret <- reprex(1:5, show = FALSE)
  expect_identical(ret, out)
})

test_that("file input works", {
  write("1:5", "foo.R")
  ret <- reprex(infile = "foo.R", show = FALSE)
  expect_identical(ret, out)
  file.remove("foo.R")
})

test_that("can't see environment of caller", {
  z <- "don't touch me"
  ret <- reprex(paste0(z, "!!!"), show = FALSE)
  expect_match(ret, "object 'z' not found", all = FALSE)
})

test_that("expression input is not evaluated in environment of caller", {
  z <- "don't touch me"
  reprex(z <- "I touched it", show = FALSE)
  expect_identical(z, "don't touch me")
})

test_that("reprex doesn't write into environment of caller", {
  z <- "don't touch me"
  ret <- reprex((z <- "I touched it!"), show = FALSE)
  expect_identical(ret[3], "#> [1] \"I touched it!\"")
  expect_identical(z, "don't touch me")

  ## concrete example I have suffered from:
  ## assign object to name of object inside reprex_()
  expect_match(reprex(r_file <- 0L, show = FALSE), "r_file <- 0L", all = FALSE)

})

test_that("Circular use is detected before render", {
  ret <- reprex(y <- 2, show = FALSE)
  expect_error(reprex(show = FALSE), "isn't valid R code")
})
