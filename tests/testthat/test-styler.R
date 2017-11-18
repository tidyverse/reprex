context("style")

test_that("ugly code gets restyled", {
  skip_if_not_installed("styler")
  ret <- reprex(
    input = c("a<-function( x){", "1+1}           "),
    style = TRUE,
    advertise = FALSE,
    render = FALSE
  )
  i <- which(ret == "#+ reprex-body")
  expect_identical(
    ret[i + 1:3],
    c("a <- function(x) {", "  1 + 1", "}")
  )
})

test_that("bang bang bang is styled correctly", {
  skip_if_not_installed("styler")
  input <- c(
    'nameshift <- c(SL = "Sepal.Length")',
    "head(dplyr::rename(iris[, 1:2], !!! nameshift), 3)"
  )
  ret <- reprex(input = input, style = TRUE, advertise = FALSE, render = FALSE)
  i <- which(ret == "#+ reprex-body")
  expect_identical(ret[i + 1:2], input)
})
