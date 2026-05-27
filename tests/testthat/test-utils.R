test_that("locate_input() works", {
  with_mocked_bindings(
    reprex_clipboard = function() TRUE,
    expect_identical("clipboard", locate_input(NULL))
  )
  with_mocked_bindings(
    reprex_clipboard = function() FALSE,
    in_rstudio = function() TRUE,
    expect_identical("selection", locate_input(NULL))
  )
  with_mocked_bindings(
    reprex_clipboard = function() FALSE,
    in_rstudio = function() FALSE,
    in_positron = function() FALSE,
    expect_snapshot(locate_input(NULL), error = TRUE)
  )
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
