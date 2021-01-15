test_that("reprex.current_venue is set", {
  skip_on_cran()
  input <- "getOption('reprex.current_venue')"
  ret <- reprex(input = paste0(input, "\n"))
  expect_match(ret, "gh", all = FALSE)
  ret <- reprex(input = paste0(input, "\n"), venue = "html")
  expect_match(ret, "html", all = FALSE)
})
