test_that(".Rprofile local to reprex target directory is consulted", {
  local_temp_wd("reprextests-aaa")
  cat("x <- 'aaa'\n", file = ".Rprofile")
  cat("x\n", file = "foo.R")
  aaa_foo <- path_abs("foo.R")

  local_temp_wd("reprextests-bbb")
  cat("x <- 'bbb'\n", file = ".Rprofile")

  out <- reprex(x, outfile = NA, advertise = FALSE)
  expect_match(out, "bbb", all = FALSE)

  out <- reprex(input = aaa_foo, outfile = NA, advertise = FALSE)
  expect_match(out, "aaa", all = FALSE)
})
