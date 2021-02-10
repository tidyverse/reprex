test_that("rstudio_text_tidy() can handle 'no input'", {
  expect_equal(rstudio_text_tidy(""), character())
})
