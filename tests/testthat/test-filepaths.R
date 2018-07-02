context("test-filepaths")

test_that("make_filebase() defaults to 'reprex' inside a dir inside tempdir", {
  x <- make_filebase(outfile = NULL, infile = NULL)
  expect_equal(fs::path_file(x), "reprex")
  expect_match(fs::path_file(fs::path_dir(x)), "^reprex")
  temp <- fs::path_real(path_temp())
  expect_identical(fs::path_common(c(x, temp)), temp)
})

test_that("make_filebase(outfile = NA) fabricates filebase in wd", {
  x <- make_filebase(outfile = NA, infile = NULL)
  expect_match(fs::path_file(x), "^reprex")
  expect_equal(fs::path_dir(x), ".")
})

test_that("make_filebase() works from relative infile, outfile", {
  expect_equal(make_filebase(outfile = NA, infile = "abcde"), "abcde")
  expect_equal(make_filebase(outfile = "abcde"), "abcde")
})

test_that("make_filebase() works from absolute infile, outfile", {
  x <- make_filebase(outfile = NA, infile = fs::path_temp("abcde"))
  expect_match(fs::path_file(x), "^abcde")
  expect_equal(fs::path_dir(x), path_temp())

  x <- make_filebase(outfile = fs::path_temp("abcde"))
  expect_match(fs::path_file(x), "^abcde")
  expect_equal(fs::path_dir(x), path_temp())
})
