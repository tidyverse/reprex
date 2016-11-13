context("expression stringification")

test_that("one statement, naked", {
  expect_identical(stringify_expression(1:5), "1:5")
})

test_that("one statement, brackets, one line", {
  expect_identical(stringify_expression({1:5}), "1:5")
})

test_that("one statement, quoted, one line", {
  expect_identical(stringify_expression(quote(mean(x))), "mean(x)")
})

test_that("one statement, brackets, multiple lines, take 1", {
  expect_identical(stringify_expression({
    1:5
  }), "1:5")
})

test_that("one statement, brackets, multiple lines, take 2", {
  expect_identical(stringify_expression({1:5
  }), "1:5")
})

test_that("one statement, brackets, multiple lines, take 3", {
  expect_identical(stringify_expression({
    1:5}), "1:5")
})

# mystery to solve
#
# trying to test an expression like this:
# reprex({1:3;4:6})
# which appears to work interactively
# but every way I think to test it fails :(
# test_that("multiple statements, brackets", {
#   expect_identical(stringify_expression(quote({1:3;4:6})), "1:3;4:6")
# })
# print(stringify_expression(quote({1:3;4:6})))
# I have to use quote, but then that causes extra stuff to be absorbed into expr
# update: I think the semicolon is a big part of the story/problem

test_that("leading comment", {
  ret <- stringify_expression(quote({
    #hi
    mean(x)
  }))
  out <- c("#hi", "mean(x)")
  expect_identical(trimws(ret), out)
})

test_that("embedded comment", {
  out <- c("x <- 1:10", "## a comment", "y")
  ret <- stringify_expression(quote({
    x <- 1:10
    ## a comment
    y
  }))
  expect_identical(trimws(ret), out)

  ret <- stringify_expression(quote({x <- 1:10
  ## a comment
  y
  }))
  expect_identical(trimws(ret), out)

  ret <- stringify_expression(quote({
    x <- 1:10
    ## a comment
    y}))
  expect_identical(trimws(ret), out)
})
