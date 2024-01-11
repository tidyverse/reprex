test_that("debugging ongoing styler cache fiddliness", {
  skip_if(getRversion() < "4.0.0")
  expect_true(fs::dir_exists(tools::R_user_dir("R.cache", which = "cache")))
})
