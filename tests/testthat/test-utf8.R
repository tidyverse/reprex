test_that("UTF-8 encoding, string input", {
  skip_on_cran()

  in_utf8 <- c(
    #       a-grave   e-diaeresis  Eth
    "x <- c('\u00C0', '\u00CB', '\u00D0')",
    "print(x)"
  )
  out_utf8 <- reprex(input = in_utf8)

  expect_in(Encoding(out_utf8), c("unknown", "UTF-8"))

  line_in <-  grep("^x <-", in_utf8, value = TRUE)
  line_out <- grep("^x <-", out_utf8, value = TRUE)
  expect_identical(charToRaw(line_in), charToRaw(line_out))

  line_out <- grep("^#> \\[1\\]", out_utf8, value = TRUE)
  expect_match(line_out, "[\u00C0]")
  expect_match(line_out, "[\u00CB]")
  expect_match(line_out, "[\u00D0]")

  in_latin1 <- iconv(in_utf8, from = "UTF-8", to = "latin1")
  out_latin1 <- reprex(input = in_latin1)

  expect_identical(
    charToRaw(paste0(out_utf8, collapse = "\n")),
    charToRaw(paste0(out_latin1, collapse = "\n"))
  )
})
