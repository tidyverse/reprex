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
