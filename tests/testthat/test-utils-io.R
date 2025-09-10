test_that("retrofit_files() works", {
  local_reprex_loud()
  withr::local_options(lifecycle_verbosity = "warning")

  # when `outfile` is not specified, there's nothing to do
  expect_equal(
    retrofit_files(infile = NULL, wd = NULL),
    list(infile = NULL, wd = NULL)
  )
  expect_equal(
    retrofit_files(infile = "foo.R", wd = "whatever"),
    list(infile = "foo.R", wd = "whatever")
  )

  # `wd` takes precedence over `outfile` and we say something
  expect_snapshot_warning(
    x <- retrofit_files(wd = "this", outfile = "that")
  )
  expect_equal(x, list(infile = NULL, wd = "this"))

  # `outfile = NA` morphs into `wd = "."`, if no `infile`
  expect_snapshot_warning(
    x <- retrofit_files(outfile = NA)
  )
  expect_equal(x, list(infile = NULL, wd = "."))

  # only `wd` is salvaged from `outfile = some/path/blah` and we mention `input`
  expect_snapshot_warning(
    x <- retrofit_files(outfile = "some/path/blah")
  )
  expect_equal(x, list(infile = NULL, wd = "some/path"))

  # `infile` takes over much of `outfile`'s previous role
  expect_snapshot_warning(
    x <- retrofit_files(infile = "a/path/foo.R", outfile = NA)
  )
  expect_equal(x, list(infile = "a/path/foo.R", wd = NULL))
  expect_snapshot_warning(
    x <- retrofit_files(infile = "a/path/foo.R", outfile = "other/path/blah")
  )
  expect_equal(x, list(infile = "a/path/foo.R", wd = NULL))
})

# root cause of
# https://github.com/tidyverse/reprex/issues/379
test_that("we don't add a suffix more than once", {
  x <- "blah_r.R"
  expect_equal(x, add_suffix(x, suffix = "r"))
})

test_that("make_filebase() works with no input", {
  x <- make_filebase(infile = NULL, wd = NULL)

  filebase_base <- path_file(x)
  # adjective-animal
  expect_match(filebase_base, "^[a-z]+[-][a-z]+$")

  filebase_parent <- path_file(path_dir(x))
  # reprex-[hexademical from tempfile()]-adjective-animal
  expect_match(filebase_parent, "^reprex-[[:xdigit:]]+[-][a-z]+[-][a-z]+$")

  temp <- path_real(path_temp())
  expect_identical(path_common(c(x, temp)), temp)
})

test_that("make_filebase(wd = '.') works", {
  x <- make_filebase(infile = NULL, wd = ".")
  expect_equal(path_dir(x), ".")
  # adjective-animal
  expect_match(x, "^[a-z]+[-][a-z]+$")
})

test_that("make_filebase(wd = 'blah') works", {
  wd <- path_temp("xyz")
  x <- make_filebase(infile = NULL, wd = wd)
  expect_equal(path_file(path_dir(x)), "xyz")
  # adjective-animal
  expect_match(path_file(x), "^[a-z]+[-][a-z]+$")
})

test_that("make_filebase(infile = 'blah') works", {
  # relative path
  expect_equal(make_filebase(infile = "foo.R"), "foo")
  expect_equal(make_filebase(infile = "blah/foo.R"), "blah/foo")

  # `wd` should be ignored
  expect_equal(make_filebase(infile = "foo.R", wd = "wut"), "foo")
  expect_equal(make_filebase(infile = "blah/foo.R", wd = "wut"), "blah/foo")

  # absolute path
  infile <- path_temp("abcde.R")
  x <- make_filebase(infile = infile)
  expect_equal(path_file(x), "abcde")
  expect_equal(path_dir(x), path_dir(infile))
})
