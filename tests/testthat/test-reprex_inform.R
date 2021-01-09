test_that("reprex_inform() is under the control of REPREX_QUIET env var", {
  local_reprex_quiet(TRUE)
  expect_message(reprex_inform("blah"), regexp = NA)

  local_reprex_loud()
  expect_message(reprex_inform("blah"), regexp = "blah")
})

test_that("reprex_inform() emits a classed condition", {
  local_reprex_loud()
  expect_message(reprex_inform("blah"), class = "reprex_message")
})

test_that("reprex_quiet() defaults to NA", {
  expect_true(is.na(reprex_quiet()))
})
