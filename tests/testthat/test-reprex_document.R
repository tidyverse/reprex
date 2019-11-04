test_that("upload.fun responds to venue", {
  x <- reprex_document(venue = "gh")
  expect_identical(x$knitr$opts_knit$upload.fun, knitr::imgur_upload)
  x <- reprex_document(venue = "r")
  expect_identical(x$knitr$opts_knit$upload.fun, identity)
})
