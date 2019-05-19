test_that("UTF-8 encoding, string input", {
  skip_on_cran()

  input <- c(
    #       a-grave   e-diaeresis  Eth
    "x <- c('\u00C0', '\u00CB', '\u00D0')",
    "print(x)"
  )
  out <- reprex(input = input, show = FALSE)

  expect_true(all(Encoding(out) %in% c("unknown", "UTF-8")))

  i_in <-  grep("^x <-", input)
  i_out <- grep("^x <-", out)
  expect_identical(charToRaw(input[i_in]), charToRaw(out[i_out]))

  i_out <- grep("^#> \\[1\\]", out)
  expect_match(out[i_out], "[\u00C0]")
  expect_match(out[i_out], "[\u00CB]")
  expect_match(out[i_out], "[\u00D0]")
})
