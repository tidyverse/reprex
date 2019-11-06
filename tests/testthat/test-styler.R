test_that("ugly code gets restyled", {
  skip_on_cran()
  skip_if_not_installed("styler")
  ret <- reprex(
    input = c("a<-function( x){", "1+1}           "),
    style = TRUE,
    advertise = FALSE,
    render = FALSE
  )
  i <- grep("^a", ret)
  expect_identical(
    ret[i + 0:2],
    c("a <- function(x) {", "  1 + 1", "}")
  )
})

test_that("bang bang bang is not mangled with parentheses", {
  skip_on_cran()
  skip_if_not_installed("styler")
  input <- c(
    'nameshift <- c(SL = "Sepal.Length")',
    "head(dplyr::rename(iris[, 1:2], !!!nameshift), 3)"
  )
  ret <- reprex(input = input, style = TRUE, advertise = FALSE, render = FALSE)
  ret <- grep("dplyr::rename", ret, value = TRUE)
  expect_match(ret, "!!!")
})
