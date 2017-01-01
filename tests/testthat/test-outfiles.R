context("outfiles")

test_that("expected outfiles are written", {
  ret <- reprex("1:5", show = FALSE, outfile = "foo")
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md"))
  expect_identical(ret, readLines("foo_reprex.md"))
  expect_match(readLines("foo_reprex.R"), "\"1:5\"", all = FALSE)
})

test_that("`.md` extension is stripped from outfile", {
  ret <- reprex("1:5", show = FALSE, outfile = "foo.md")
  on.exit(file.remove("foo_reprex.R", "foo_reprex.md"))
  expect_true(file.exists("foo_reprex.R"))
  expect_length(list.files(pattern = "foo.md"), 0)
})

test_that(".R outfile doesn't clobber .R infile", {
  writeLines("1:5", "foo.R")
  on.exit(file.remove("foo.R", "foo_reprex.R", "foo_reprex.md"))
  ret <- reprex(input = "foo.R", show = FALSE, outfile = "foo")
  expect_identical("1:5", readLines("foo.R"))
})
