test_that("reprex_clipboard() works", {
  withr::local_options(list(reprex.clipboard = FALSE))
  expect_false(reprex_clipboard())
})

test_that("reprex_clipboard() insists on length one logical", {
  withr::local_options(list(reprex.clipboard = function() "wut"))
  expect_error(reprex_clipboard())
})

test_that("ingest_clipboard() copes when clipboard not available", {
  withr::local_options(list(reprex.clipboard = FALSE))
  local_reprex_loud()
  msg <- capture_messages(
    out <- ingest_clipboard()
  )
  expect_equal(out, character())
  expect_match(msg, "clipboard is not available")
})
