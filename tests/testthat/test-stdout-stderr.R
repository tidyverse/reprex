context("stdout-stderr")

test_that("stdout is captured", {
  skip_on_cran()
  out <- reprex(system2("echo", args = "blah"), std_out_err = TRUE, show = FALSE)
  expect_match(out, "standard output and standard error", all = FALSE)
  expect_match(out, "blah", all = FALSE)
})

test_that("stdout placeholder appears if nothing is captured", {
  skip_on_cran()
  out <- reprex(1:4, std_out_err = TRUE, show = FALSE)
  expect_match(out, "standard output and standard error", all = FALSE)
  expect_match(out, "nothing to show", all = FALSE)
})

test_that("stdout placeholder is absent if explicitly excluded", {
  skip_on_cran()
  out <- reprex(1:4, std_out_err = FALSE, show = FALSE)
  expect_false(any(grepl("standard output and standard error", out)))
})
