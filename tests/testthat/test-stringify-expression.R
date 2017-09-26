context("expression stringification")

test_that("simple statements are stringified", {
  expect_identical(stringify_expression(1:5), "1:5")
  expect_identical(stringify_expression({1:5}), "1:5")
  expect_identical(stringify_expression(quote(mean(x))), "mean(x)")
})

## it is very difficult to create quoted multi-line expressions in tests
## that mimic what a user can create interactively re: the srcrefs
## therefore, I executed this interactively to create expressions.rds
if (FALSE) {
  e <- new.env()
  e$e01 <- quote({
    1:5
  })
  e$e02 <- quote({1:5
  })
  e$e03 <- quote({
    1:5})
  e$e04 <- quote({1:3;4:6})
  e$e05 <- quote({
    #' Leading comment
    x <- rnorm(3)
    #' Embedded comment
    mean(x)
    #' Trailing comment
  })
  e$e06 <- quote({mean(1:4) # comment
  })
  e$e07 <- quote({
    #' Leading comment
    y <- 1:4 # comment
    #' Trailing comment
  }
  )
  saveRDS(e, rprojroot::find_testthat_root_file("expressions.rds"))
}

e <- readRDS(rprojroot::find_testthat_root_file("expressions.rds"))

test_that("one statement, brackets, multiple lines, take 1", {
  # quote({
  #   1:5
  # })
  expect_identical(
    stringify_expression(e$e01),
    "1:5"
  )
})

test_that("one statement, brackets, multiple lines, take 2", {
  # expr <- quote({1:5
  # })
  expect_identical(
    stringify_expression(e$e02),
    "1:5"
  )
})

test_that("one statement, brackets, multiple lines, take 3", {
  # expr <- quote({
  #   1:5})
  expect_identical(
    stringify_expression(e$e03),
    "1:5"
  )
})

test_that("multiple statements, brackets, semicolon", {
  # quote({1:3;4:6})
  expect_identical(
    stringify_expression(e$e04),
    "1:3;4:6"
  )
})

test_that("leading, embedded, trailing comment, #89", {
  # expr <- quote({
  #   #' Leading comment
  #   x <- rnorm(3)
  #   #' Embedded comment
  #   mean(x)
  #   #' Trailing comment
  # })
  out <- c(
    "#' Leading comment",
    "x <- rnorm(3)",
    "#' Embedded comment",
    "mean(x)",
    "#' Trailing comment"
  )
  expect_identical(
    stringify_expression(e$e05),
    out
  )
})

test_that("trailing inline comment, #91", {
  # expr <- quote({mean(1:4) # comment
  # })
  out <- "mean(1:4) # comment"
  expect_identical(
    stringify_expression(e$e06),
    out
  )
})

test_that("trailing inline comment AND trailing comment line", {
  # expr <- quote({
  #   #' Leading comment
  #   y <- 1:4 # comment
  #   #' Trailing comment
  # }
  out <- c(
    "#' Leading comment",
    "y <- 1:4 # comment",
    "#' Trailing comment"
  )
  expect_identical(
    stringify_expression(e$e07),
    out
  )
})
