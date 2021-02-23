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

test_that("preview() works with the 'Knit' button", {
  skip_on_cran()

  local_temp_wd()
  write_lines("3 * 5\n", "foo.R")
  reprex(input = "foo.R")

  withr::local_envvar(c(RMARKDOWN_PREVIEW_DIR = "."))
  rlang::local_interactive(FALSE)

  msg <- capture.output(
    preview_file <- preview("foo_reprex.md"),
    type = "message"
  )

  expect_true(file_exists("foo_reprex_preview.html"))
  expect_equal(path_file(preview_file), "foo_reprex_preview.html")
  expect_messages_to_include(
    msg,
    c("^Preview created:", "foo_reprex_preview.html$")
  )
})

test_that("preview() calls viewer() in the interactive RStudio scenario", {
  skip_on_cran()

  local_temp_wd()
  write_lines("10 / 5\n", "foo.R")
  reprex(input = "foo.R")

  rlang::local_interactive(TRUE)
  local_options(viewer = function(...) cat("viewer!", file = stderr()))

  msg <- capture.output(
    preview_file <- preview("foo_reprex.md"),
    type = "message"
  )

  expect_true(file_exists(preview_file))
  expect_equal(path_file(preview_file), "foo_reprex_preview.html")
  expect_messages_to_include(msg, "viewer!")
})
