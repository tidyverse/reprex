test_that(".Rprofile local to reprex target directory is consulted & messaged", {
  local_temp_wd("reprextests-aaa-")
  cat("x <- 'aaa'\n", file = ".Rprofile")
  cat("x\n", file = "foo.R")
  aaa_foo <- path_abs("foo.R")

  local_temp_wd("reprextests-bbb-")
  cat("x <- 'bbb'\n", file = ".Rprofile")

  local_reprex_loud()
  msg <- capture_messages(
    out <- reprex(x, wd = ".", advertise = FALSE)
  )
  expect_match(out, "bbb", all = FALSE)
  expect_messages_to_include(
    msg,
    c("Local `[.]Rprofile` detected", "bbb")
  )

  msg <- capture_messages(
    out <- reprex(input = aaa_foo, wd = ".", advertise = FALSE)
  )
  expect_match(out, "aaa", all = FALSE)
  expect_messages_to_include(
    msg,
    c("Local `[.]Rprofile` detected", "aaa")
  )
})

test_that("local .Rprofile reporting responds to venue", {
  expect_snapshot(rprofile_alert("gh"))
  expect_snapshot(rprofile_alert("r"))
})

test_that("local .Rprofile not reported when it's not there", {
  local_reprex_loud()
  msg <- capture_messages(
    reprex(1 + 1, advertise = FALSE)
  )
  expect_false(any(grepl(".Rprofile", msg, fixed = TRUE)))
})
