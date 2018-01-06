context("utils")

test_that("nope() defaults to 'yes' if user not available", {
  expect_false(nope())
})

test_that("yep() defaults to 'no' if user not available", {
  expect_false(yep())
})
