## https://github.com/tidyverse/reprex/issues/152
test_that("keep.source is TRUE inside the reprex()", {
  skip_on_cran()
  ret <- reprex(input = "getOption('keep.source')\n")
  expect_match(ret, "TRUE", all = FALSE)
})

test_that("reprex() works with code that deals with srcrefs", {
  skip_on_cran()
  ret <- reprex(
    input = "utils::getParseData(parse(text = 'a'))\n",
    advertise = FALSE
  )
  expect_snapshot_output(print(ret))
})

## https://github.com/tidyverse/reprex/issues/183
test_that("reprex() doesn't leak files by default", {
  skip_on_cran()
  reprex(base::writeLines("test", "test.txt"), advertise = FALSE)
  ret <- reprex(base::readLines("test.txt"), advertise = FALSE)
  expect_match(ret, "cannot open file 'test.txt'", all = FALSE)
})

test_that("rmarkdown::render() context is trimmed from rlang backtrace", {
  skip_on_cran()
  input <- c(
    "f <- function() rlang::abort('foo')",
    "f()",
    "rlang::last_error()",
    "rlang::last_trace()"
  )
  ret <- reprex(input = input, advertise = FALSE)
  expect_no_match(ret, regexp = "tryCatch|rmarkdown::render")
})

test_that("rlang::last_error() and last_trace() work", {
  skip_on_cran()

  input <- c(
    "f <- function() rlang::abort('foo')",
    "f()",
    # as of rlang 1.0.0 (2022-01-26)
    # https://github.com/r-lib/rlang/blame/0e2718639d7b87effbf47cf17d6e0288a69454e6/NEWS.md#L350-L354
    "#'", # currently, this must be in a new chunk
    "rlang::last_error()",
    "rlang::last_trace()"
  )
  ret <- reprex(input = input, advertise = FALSE)
  m <- match("rlang::last_error()", ret)
  expect_no_match(ret[m + 1], "Error")
  m <- match("rlang::last_trace()", ret)
  expect_no_match(ret[m + 1], "Error")
})

test_that("reprex() works even if user uses fancy quotes", {
  skip_on_cran()
  withr::local_options(list(useFancyQuotes = TRUE))
  # use non-default venue to force some quoted yaml to be written
  expect_no_error(reprex(1, venue = "R"))
})

test_that("reprex() errors for an R crash, by default", {
  skip_on_cran()
  expect_snapshot(error = TRUE, {
    code <- 'rlang::node_car(0)\n'
    reprex(input = code)
  })
})

test_that("reprex() copes with an R crash, when `std_out_err = TRUE`", {
  skip_on_cran()
  code <- 'rlang::node_car(0)\n'
  expect_no_error(
    out <- reprex(input = code, std_out_err = TRUE)
  )

  skip_on_os("windows")

  scrubber <- function(x) {
    # I don't want to snapshot the actual traceback
    out <- x[seq_len(min(grep("Traceback", x)))]
    # on macOS and windows, cause is 'invalid permissions'
    # on ubuntu, cause is 'memory not mapped'
    out <- sub(
      "address 0x[0-9a-fA-F]+, cause '.*'",
      "address ADDRESS, cause 'CAUSE'",
      out
    )
    trimws(out)
  }

  expect_snapshot(out, transform = scrubber)
})

## https://github.com/posit-dev/positron/issues/11578
test_that("reprex() works with bare expression from sourced file with #line directive", {
  skip_on_cran()

  code <- c(
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "",
    "#line 1",
    "reprex::reprex({",
    "  1 + 1",
    "}, advertise = FALSE)"
  )

  tmp <- withr::local_tempfile(fileext = ".R")
  write_lines(code, tmp)

  expect_snapshot({
    base::writeLines(source(tmp)$value)
  })
})
