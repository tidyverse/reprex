## https://github.com/tidyverse/reprex/issues/152
test_that("keep.source is TRUE inside the reprex()", {
  skip_on_cran()
  ret <- reprex(
    input = "getOption('keep.source')\n",
    show = FALSE, advertise = FALSE
  )
  expect_match(ret, "TRUE", all = FALSE)
})

test_that("reprex() works with code that deals with srcrefs", {
  skip_on_cran()
  ret <- reprex(
    input = "utils::getParseData(parse(text = 'a'))\n",
    show = FALSE, advertise = FALSE
  )
  expect_known_output(print(ret), test_path("reference/srcref_reprex"))
})

## https://github.com/tidyverse/reprex/issues/183
test_that("reprex() doesn't leak files by default", {
  skip_on_cran()
  reprex(base::writeLines("test", "test.txt"), show = FALSE, advertise = FALSE)
  ret <- reprex(base::readLines("test.txt"), show = FALSE, advertise = FALSE)
  expect_match(ret, "cannot open file 'test.txt'", all = FALSE)
})

test_that("rmarkdown::render() context is trimmed from rlang backtrace", {
  skip_on_cran()
  input <- "f <- function() g(); g <- function() h(); h <- function() rlang::abort('foo'); f()\n"
  ret <- reprex(input = input, show = FALSE, advertise = FALSE)
  expect_false(any(grepl("tryCatch", ret)))
  expect_false(any(grepl("rmarkdown::render", ret)))
})
