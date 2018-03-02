context("reprex")

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
