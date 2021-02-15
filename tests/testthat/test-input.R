# test_that("reprex: clipboard input works")
# This test was removed:
#   * Feels like I'm just testing clipr, which seems silly.
#   * Because clipr and reprex have erected so many safeguards against
#     clipboard access in a noninteractive session, for CRAN reasons, this test
#     requires a great deal of gymnastics to bypass all of that.
#   * Normal usage will absolutely and immediately reveal clipboard problems.

test_that("reprex: expression input works", {
  expect_snapshot(cli::cat_line(
    reprex({x <- 1:5; mean(x)}, render = FALSE)
  ))
})

## https://github.com/tidyverse/reprex/issues/241
test_that("reprex: expression input preserves `!!`", {
  res <- reprex(
    {f <- function(c6d573e) rlang::qq_show(how_many(!!rlang::enquo(c6d573e)))},
    render = FALSE
  )
  expect_match(res, "!!rlang::enquo(c6d573e)", all = FALSE, fixed = TRUE)
})

test_that("reprex: character input works", {
  expect_snapshot(cli::cat_line(
    reprex(input = c("x <- 5:1", "mean(x)"), render = FALSE)
  ))
})

test_that("reprex: file input works", {
  local_temp_wd()
  write_lines(c("x <- 6:10", "mean(x)"), "foo.R")
  expect_snapshot(cli::cat_line(
    reprex(input = "foo.R", render = FALSE)
  ))
})

test_that("reprex: file input in a subdirectory works", {
  local_temp_wd()
  dir_create("foo")
  write_lines(c("x <- 11:15", "mean(x)"),  path("foo", "foo.R"))
  expect_snapshot(cli::cat_line(
    reprex(input = path("foo", "foo.R"), render = FALSE)
  ))
})

test_that("Circular use is detected before source file written", {
  skip_on_cran()
  ret <- reprex(exp(1), venue = "gh")
  expect_error(reprex(input = ret, render = FALSE), "Aborting")
  ret <- reprex(exp(1), venue = "r")
  expect_error(reprex(input = ret, render = FALSE), "Aborting")
  ret <- reprex(exp(1), venue = "html")
  expect_error(reprex(input = ret, render = FALSE), "Aborting")
})

test_that("Leading prompts are removed", {
  skip_on_cran()

  input <- c("x <- 1:3", "median(x)")
  res <- reprex(input = input, render = FALSE)
  input2 <- paste0(getOption("prompt"), input)

  local_reprex_loud()
  expect_snapshot(
    res2 <- reprex(input = input2, render = FALSE)
  )
  expect_identical(res, res2)
})

test_that("newlines in code are protected and uniformly so across venues", {
  # NOTE: use of single vs double quotes is counter-intuitive, but deliberate
  input <- 'paste(letters[1:3], collapse = "\n")\n'
  chr_input <- reprex(input = input, render = FALSE)

  input_file <- path_temp("foo.R")
  withr::local_file(input_file)
  write_lines(
    escape_newlines('paste(letters[1:3], collapse = "\n")'),
    input_file
  )
  path_input <- reprex(input = input_file, render = FALSE)

  expr_input <- reprex(paste(letters[1:3], collapse = "\n"), render = FALSE)

  expect_identical(chr_input, path_input)
  expect_identical(chr_input, expr_input)
})
