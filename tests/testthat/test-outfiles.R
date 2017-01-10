context("outfiles")

base_msg <- c(
  "Preparing reprex as .R file to render:\n  * foo_reprex.R\n",
  "Writing reprex markdown:\n  * foo_reprex.md\n"
)

clip_msg <- switch(
  as.character(clipboard_available()),
  `TRUE` = "Rendered reprex is on the clipboard.",
  "Unable to put result on the clipboard")

test_that("expected outfiles are written and messaged, venue = 'gh'", {
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md"))
  msg <- capture_messages(ret <- reprex(1:5, outfile = "foo", show = FALSE))
  expect_identical(msg[1:2], base_msg)
  expect_match(msg[3], clip_msg)
  expect_match(readLines("foo_reprex.R"), "1:5", all = FALSE)
  expect_identical(ret, readLines("foo_reprex.md"))
})

test_that("expected outfiles are written and messaged, venue = 'R'", {
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md", "foo_rendered.R"))
  msg <- capture_messages(ret <- reprex(1:5, outfile = "foo",
                                         show = FALSE, venue = "R"))
  expect_identical(msg[1:2], base_msg)
  expect_identical(msg[3],
                   "Writing reprex as commented R script:\n  * foo_rendered.R\n")
  expect_match(msg[4], clip_msg)
  expect_match(readLines("foo_reprex.R"), "1:5", all = FALSE)
  expect_identical(ret, readLines("foo_rendered.R"))
  expect_match(readLines("foo_reprex.md"), "1:5", all = FALSE)
})

test_that("`.md` extension is stripped from outfile", {
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md"))
  ret <- reprex(1:5, show = FALSE, outfile = "foo.md")
  expect_true(file.exists("foo_reprex.R"))
  expect_length(list.files(pattern = "foo.md"), 0)
})

test_that(".R outfile doesn't clobber .R infile", {
  on.exit(file.remove("foo.R", "foo_reprex.R", "foo_reprex.md"))
  writeLines("1:5", "foo.R")
  ret <- reprex(input = "foo.R", show = FALSE, outfile = NA)
  expect_identical("1:5", readLines("foo.R"))
})

test_that("outfiles in a subdirectory works", {
  on.exit(unlink("foo", recursive = TRUE))
  dir.create("foo")
  msg <- capture_messages(ret <- reprex(1:5, outfile = "foo/foo", show = FALSE))
  base_msg <- gsub("foo", "foo/foo", base_msg)
  expect_identical(msg[1:2], base_msg)
  expect_match(msg[3], clip_msg)
})

test_that("outfiles based on input file", {
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md"))
  writeLines("1:5", "foo.R")
  msg <-
    capture_messages(ret <- reprex(input = "foo.R", show = FALSE, outfile = NA))
  expect_true(file.exists("foo_reprex.md"))
  expect_identical(msg[1:2], base_msg)
})

test_that("outfiles based on tempfile()", {
  msg <-
    capture_messages(ret <- reprex(input = c("x <- 1:3", "min(x)"),
                                   show = FALSE, outfile = NA))
  tempbase <- gsub(".*(file.*)_.*", "\\1", msg[1])
  r_file <- paste0(tempbase, "_reprex.R")
  md_file <- paste0(tempbase, "_reprex.md")
  on.exit(file.remove(r_file, md_file))
  expect_true(file.exists(r_file))
  expect_true(file.exists(md_file))
  base_msg <- gsub("foo", tempbase, base_msg)
  expect_identical(msg[1:2], base_msg)
})

test_that("pre-existing foo_reprex.R isn't get clobbered, w/o user's OK", {
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md"))
  ret <- reprex(min(1L), show = FALSE, outfile = "foo")
  expect_match(readLines("foo_reprex.md"), "min(1L)", all = FALSE, fixed = TRUE)
  expect_output(reprex(max(2L), show = FALSE, outfile = "foo"),
                "Exiting")
  expect_match(readLines("foo_reprex.md"), "min(1L)", all = FALSE, fixed = TRUE)
})
