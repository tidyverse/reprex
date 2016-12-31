context("outfiles")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

test_that("reprex is written to outfile", {
  ret <- reprex("1:5", show = FALSE, outfile = "foo")
  on.exit(file.remove("foo.R", "foo.md"))
  expect_identical(ret, readLines("foo.md"))
  expect_match(readLines("foo.R"), "\"1:5\"", all = FALSE)
})

test_that("`.md` extension is stripped from outfile", {
  ret <- reprex("1:5", show = FALSE, outfile = "foo.md")
  on.exit(file.remove("foo.R", "foo.md"))
  expect_identical(ret, readLines("foo.md"))
})

test_that(".R outfile doesn't clobber .R infile", {
  writeLines("1:5", "foo.R")
  on.exit(file.remove("foo.R", "foo-reprex.R", "foo-reprex.md"))
  expect_message(ret <- reprex(input = "foo.R", show = FALSE, outfile = "foo"),
                 "Writing output files to 'foo-reprex.*' to protect 'foo.R'.")
})
