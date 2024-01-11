test_that("UTF-8 encoding, string input", {
  skip_on_cran()

  in_utf8 <- c(
    #       a-grave   e-diaeresis  Eth
    "x <- c('\u00C0', '\u00CB', '\u00D0')",
    "print(x)"
  )
  out_utf8 <- reprex(input = in_utf8)

  expect_true(all(Encoding(out_utf8) %in% c("unknown", "UTF-8")))

  i_in <-  grep("^x <-", in_utf8)
  i_out <- grep("^x <-", out_utf8)
  expect_identical(charToRaw(in_utf8[i_in]), charToRaw(out_utf8[i_out]))

  i_out <- grep("^#> \\[1\\]", out_utf8)
  expect_match(out_utf8[i_out], "[\u00C0]")
  expect_match(out_utf8[i_out], "[\u00CB]")
  expect_match(out_utf8[i_out], "[\u00D0]")

  in_latin1 <- iconv(in_utf8, from = "UTF-8", to = "latin1")
  out_latin1 <- reprex(input = in_latin1)

  expect_identical(
    charToRaw(paste0(out_utf8, collapse = "\n")),
    charToRaw(paste0(out_latin1, collapse = "\n"))
  )
})
