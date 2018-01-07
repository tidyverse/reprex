context("stdout-stderr")

test_that("stdout is captured", {
  out <- reprex(system2("echo", args = "blah"), std_out_err = TRUE, show = FALSE)
  expect_match(out, "standard output and standard error", all = FALSE)
  expect_match(out, "#> blah", all = FALSE)
})

test_that("stdout placeholder appears if nothing is captured", {
  out <- reprex(1:4, std_out_err = TRUE, show = FALSE)
  expect_match(out, "standard output and standard error", all = FALSE)
  expect_match(out, "#> nothing written to stdout or stderr", all = FALSE)
})
