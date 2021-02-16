test_that("reprex_quiet() defaults to NA", {
  expect_true(is.na(reprex_quiet()))
})

test_that("reprex_alert() and friends work", {
  local_reprex_loud()

  expect_snapshot({
    reprex_alert("alert", type = "")
    reprex_success("success")
    reprex_info("info")
    reprex_warning("warning")
    reprex_danger("danger")
  })
})

test_that("reprex_alert() is under the control of REPREX_QUIET env var", {
  local_reprex_quiet()
  expect_snapshot(reprex_alert("alert", type = ""))

  local_reprex_loud()
  expect_snapshot(reprex_alert("alert", type = ""))
})

test_that("reprex_path() works and respects REPREX_QUIET", {
  local_reprex_quiet()
  expect_snapshot(reprex_path("Something descriptive:", "path/to/file"))

  local_reprex_loud()
  expect_snapshot({
    reprex_path("Something descriptive:", "path/to/file")
    x <- "path/to/file"
    reprex_path("Something descriptive:", x)
    y <- c("path", "to", "file")
    reprex_path("Something descriptive:", path_join(y))
  })
})
