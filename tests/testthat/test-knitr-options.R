test_that("`comment` works", {
  skip_on_cran()
  out <- reprex(1, comment = "#?#")
  expect_match(out, "#?#", all = FALSE, fixed = TRUE)
})

test_that("reprex() suppresses tidyverse startup message by default", {
  skip_on_cran()
  skip_if_not_installed("tidyverse", minimum_version = "1.2.1")
  ret <- reprex(input = sprintf("library(%s)\n", "tidyverse"))
  expect_false(any(grepl("Attaching", ret)))
})

test_that("`tidyverse_quiet` works", {
  skip_on_cran()
  skip_if_not_installed("tidyverse", minimum_version = "1.2.1")

  ret <- reprex(
    input = "library(tidyverse)\n",
    tidyverse_quiet = TRUE
  )
  expect_false(any(grepl("Attaching", ret)))

  ret <- reprex(
    input = "library(tidyverse)\n",
    tidyverse_quiet = FALSE
  )
  expect_match(ret, "Attaching", all = FALSE)
})

test_that("`tidyverse_quiet` works for tidymodels", {
  skip_on_cran()
  skip_if_not_installed("tidymodels")

  ret <- reprex(
    input = "library(tidymodels)\n",
    tidyverse_quiet = TRUE
  )
  expect_false(any(grepl("Attaching", ret)))

  ret <- reprex(
    input = "library(tidymodels)\n",
    tidyverse_quiet = FALSE
  )
  expect_match(ret, "Attaching", all = FALSE)

})


test_that("`style` works", {
  skip_on_cran()
  skip_if_not_installed("styler")
  ret <- reprex(input = c("a<-function( x){", "1+1}           "), style = TRUE)
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
  ret <- reprex(input = input, style = TRUE)
  ret <- grep("dplyr::rename", ret, value = TRUE)
  expect_match(ret, "!!!")
})
