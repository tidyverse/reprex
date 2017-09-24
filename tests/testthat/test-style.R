context("style")

test_that("expression input get restyled", {
  ret <- reprex(a<-function( x){1+1}           , show = FALSE)
  out <- c("``` r", "a <- function(x) {", "    1 + 1", "}", "```")
  expect_identical(ret, out)
})

test_that("bang bang bang is styled correctly", {
  skip_if_not_installed("dplyr", minimum_version = "0.7.0")
  input <- c(
    "nameshift <- c(SL = 'Sepal.Length')",
    "head(dplyr::rename(iris[, 1:2], !!!nameshift), 3)"
  )
  out <- reprex(input = input, show = FALSE)
  expect_identical(out[2:3], input)
})
