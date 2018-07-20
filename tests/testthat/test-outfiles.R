context("outfiles")

base_msg <- c(
  "Preparing reprex as .R file:\n  * foo_reprex.R\n",
  "Rendering reprex...\n",
  "Writing reprex markdown:\n  * foo_reprex.md\n"
)

test_that("expected outfiles are written and messaged, venue = 'gh'", {
  skip_on_cran()
  temporarily()
  withr::local_file(c("foo_reprex.R", "foo_reprex.md"))
  msg <- capture_messages(ret <- reprex(1:5, outfile = "foo", show = FALSE))
  expect_identical(msg[1:3], base_msg)
  expect_match(readLines("foo_reprex.R"), "1:5", all = FALSE)
  expect_identical(ret, readLines("foo_reprex.md"))
})

test_that("expected outfiles are written and messaged, venue = 'R'", {
  skip_on_cran()
  temporarily()
  withr::local_file(c("foo_reprex.R", "foo_reprex.md", "foo_reprex_rendered.R"))
  msg <- capture_messages(
    ret <- reprex(1:5, outfile = "foo", show = FALSE, venue = "R")
  )
  expect_identical(msg[1:3], base_msg)
  expect_identical(
    msg[4],
    "Writing reprex as commented R script:\n  * foo_reprex_rendered.R\n"
  )
  expect_match(readLines("foo_reprex.R"), "1:5", all = FALSE)
  expect_identical(ret, readLines("foo_reprex_rendered.R"))
  expect_match(readLines("foo_reprex.md"), "1:5", all = FALSE)
})

test_that("`.md` extension is stripped from outfile", {
  skip_on_cran()
  temporarily()
  withr::local_file(c("foo_reprex.R", "foo_reprex.md"))
  ret <- reprex(1:5, show = FALSE, outfile = "foo.md")
  expect_true(file_exists("foo_reprex.R"))
  expect_length(dir_ls(regexp = "foo.md"), 0)
})

test_that(".R outfile doesn't clobber .R infile", {
  skip_on_cran()
  temporarily()
  withr::local_file(c("foo.R", "foo_reprex.R", "foo_reprex.md"))
  writeLines("1:5", "foo.R")
  ret <- reprex(input = "foo.R", show = FALSE, outfile = NA)
  expect_identical("1:5", readLines("foo.R"))
})

test_that("outfiles in a subdirectory works", {
  skip_on_cran()
  temporarily()
  withr::defer(dir_delete("foo"))
  dir_create("foo")
  msg <- capture_messages(
    ret <- reprex(1:5, outfile = "foo/foo", show = FALSE)
  )
  exp_msg <- gsub("foo", "foo/foo", base_msg)
  expect_identical(msg[1:3], exp_msg)
})

test_that("outfiles based on input file", {
  skip_on_cran()
  temporarily()
  withr::local_file(c("foo.R", "foo_reprex.R", "foo_reprex.md"))
  writeLines("1:5", "foo.R")
  msg <- capture_messages(
    ret <- reprex(input = "foo.R", show = FALSE, outfile = NA)
  )
  expect_true(file_exists("foo_reprex.md"))
  expect_identical(msg[1:3], base_msg)
})

test_that("outfiles based on tempfile()", {
  skip_on_cran()
  temporarily()
  msg <- capture_messages(
    ret <- reprex(input = c("x <- 1:3", "min(x)"), show = FALSE, outfile = NA)
  )
  tempbase <- gsub(".*(reprex.*)_.*", "\\1", msg[1])
  r_file <- paste0(tempbase, "_reprex.R")
  md_file <- paste0(tempbase, "_reprex.md")
  withr::local_file(c(r_file, md_file))
  expect_true(file_exists(r_file))
  expect_true(file_exists(md_file))
  exp_msg <- gsub("foo", tempbase, base_msg)
  expect_identical(msg[1:3], exp_msg)
})

test_that("pre-existing foo_reprex.R doesn't get clobbered w/o user's OK", {
  skip_on_cran()
  temporarily()
  withr::local_file(c("foo_reprex.R", "foo_reprex.md"))
  ret <- reprex(1:3, show = FALSE, outfile = "foo")
  expect_match(readLines("foo_reprex.md"), "1:3", all = FALSE, fixed = TRUE)
  reprex(max(4:6), show = FALSE, outfile = "foo")
  expect_match(readLines("foo_reprex.md"), "1:3", all = FALSE, fixed = TRUE)
})
