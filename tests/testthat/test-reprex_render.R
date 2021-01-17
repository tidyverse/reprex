# https://github.com/tidyverse/reprex/issues/349
test_that("reprex additions are added to a *copy* of an Rmd input file", {
  skip_on_cran()
  fixture_path <- path_abs(test_path("fixtures/a-reprex-document.Rmd"))
  local_temp_wd()

  file_copy(fixture_path, "foo.Rmd")
  n_before <- read_lines("foo.Rmd")
  reprex_render("foo.Rmd")
  n_after <- read_lines("foo.Rmd")
  expect_equal(n_before, n_after)
})
