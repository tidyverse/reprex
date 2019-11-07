expect_messages_to_include <- function(haystack, needles) {
  lapply(
    needles,
    function(x) expect_match(haystack, x, all = FALSE, fixed = TRUE)
  )
  invisible()
}

test_that("expected outfiles are written and messaged, venue = 'gh'", {
  skip_on_cran()
  scoped_temporary_wd()

  msg <- capture_messages(
    ret <- reprex(1:5, outfile = "foo")
  )
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .R file", "foo_reprex.R",
      "Writing reprex markdown", "foo_reprex.md"
    )
  )
  expect_match(read_lines("foo_reprex.R"), "1:5", all = FALSE)
  expect_identical(ret, read_lines("foo_reprex.md"))
})

test_that("expected outfiles are written and messaged, venue = 'R'", {
  skip_on_cran()
  scoped_temporary_wd()

  msg <- capture_messages(
    ret <- reprex(1:5, outfile = "foo", venue = "R")
  )
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .R file", "foo_reprex.R",
      "Writing reprex markdown", "foo_reprex.md",
      "Writing reprex as commented R script:", "foo_reprex_rendered.R"
    )
  )
  expect_match(read_lines("foo_reprex.R"), "1:5", all = FALSE)
  expect_identical(ret, read_lines("foo_reprex_rendered.R"))
  expect_match(read_lines("foo_reprex.md"), "1:5", all = FALSE)
})

test_that("`.md` extension is stripped from outfile", {
  skip_on_cran()
  scoped_temporary_wd()

  ret <- reprex(1:5, outfile = "foo.md")
  expect_true(file_exists("foo_reprex.R"))
  expect_length(dir_ls(regexp = "foo.md"), 0)
})

test_that(".R outfile doesn't clobber .R infile", {
  skip_on_cran()
  scoped_temporary_wd()

  write_lines("1:5", "foo.R")
  ret <- reprex(input = "foo.R", outfile = NA)
  expect_identical("1:5", read_lines("foo.R"))
})

test_that("outfiles in a subdirectory works", {
  skip_on_cran()
  scoped_temporary_wd()

  dir_create("foo")
  msg <- capture_messages(
    ret <- reprex(1:5, outfile = "foo/foo")
  )
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .R file", "foo/foo_reprex.R",
      "Writing reprex markdown", "foo/foo_reprex.md"
    )
  )
})

test_that("outfiles based on input file", {
  skip_on_cran()
  scoped_temporary_wd()

  write_lines("1:5", "foo.R")
  msg <- capture_messages(
    ret <- reprex(input = "foo.R", outfile = NA)
  )
  expect_true(file_exists("foo_reprex.md"))
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .R file", "foo_reprex.R",
      "Writing reprex markdown", "foo_reprex.md"
    )
  )
})

test_that("outfiles based on tempfile()", {
  skip_on_cran()
  scoped_temporary_wd()

  msg <- capture_messages(
    ret <- reprex(input = c("x <- 1:3", "min(x)"), outfile = NA)
  )
  prep <- grep("Preparing", msg)
  tempbase <- gsub(".*(reprex.*)_.*", "\\1", msg[prep])
  r_file <- paste0(tempbase, "_reprex.R")
  md_file <- paste0(tempbase, "_reprex.md")
  expect_true(file_exists(r_file))
  expect_true(file_exists(md_file))
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .R file", r_file,
      "Writing reprex markdown", md_file
    )
  )
})

test_that("pre-existing foo_reprex.R doesn't get clobbered w/o user's OK", {
  skip_on_cran()
  scoped_temporary_wd()

  ret <- reprex(1:3, outfile = "foo")
  expect_match(read_lines("foo_reprex.md"), "1:3", all = FALSE, fixed = TRUE)
  reprex(max(4:6), outfile = "foo")
  expect_match(read_lines("foo_reprex.md"), "1:3", all = FALSE, fixed = TRUE)
})
