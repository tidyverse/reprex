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

test_that("remove_info_strings() gets rid of 'info strings'", {
  f <- function(x) strsplit(glue::glue(x), split = "\n")[[1]]
  # examples from https://spec.commonmark.org/0.29/#info-string
  x <- f("
    ```
    <
     >
    ```")
  expect_equal(x, remove_info_strings(x))

  x <- f("
    ```ruby
    def foo(x)
      return 3
    end
    ```")
  expect_equal(sub("ruby", "", x), remove_info_strings(x))

  x <- f("
    ``` ruby startline=3 $%@#$
    def foo(x)
      return 3
    end
    ```")
  expect_equal(c("```", tail(x, -1)), remove_info_strings(x))
})
