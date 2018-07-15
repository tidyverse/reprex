context("utils")

test_that("locate_input() works", {
  expect_identical("clipboard", locate_input(NULL))
  expect_identical("path", locate_input(path_temp()))
  expect_identical("input", locate_input(c("a", "b")))
  expect_identical("input", locate_input("a\n"))
})

test_that("nope() defaults to 'yes' if user not available", {
  expect_false(nope())
})

test_that("yep() defaults to 'no' if user not available", {
  expect_false(yep())
})
