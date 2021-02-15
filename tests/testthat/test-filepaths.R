test_that("make_filebase() with zero user input", {
  x <- make_filebase(outfile = NULL, infile = NULL)

  filebase_base <- fs::path_file(x)
  # adjective-animal
  expect_match(filebase_base, "^[a-z]+[-][a-z]+$")

  filebase_parent <- fs::path_file(fs::path_dir(x))
  # reprex-[hexademical from tempfile()]-adjective-animal
  expect_match(filebase_parent, "^reprex-[[:xdigit:]]+[-][a-z]+[-][a-z]+$")

  temp <- fs::path_real(path_temp())
  expect_identical(fs::path_common(c(x, temp)), temp)
})

test_that("make_filebase(outfile = NA) fabricates filebase in wd", {
  x <- make_filebase(outfile = NA, infile = NULL)
  # adjective-animal
  expect_match(x, "^[a-z]+[-][a-z]+$")
  expect_equal(fs::path_dir(x), ".")
})

test_that("make_filebase() works from relative infile, outfile", {
  expect_equal(make_filebase(outfile = NA, infile = "abcde"), "abcde")
  expect_equal(make_filebase(outfile = "abcde"), "abcde")
})

test_that("make_filebase() works from absolute infile, outfile", {
  x <- make_filebase(outfile = NA, infile = fs::path_temp("abcde"))
  expect_match(fs::path_file(x), "^abcde")
  expect_equal(fs::path_dir(x), as.character(path_temp()))

  x <- make_filebase(outfile = fs::path_temp("abcde"))
  expect_match(fs::path_file(x), "^abcde")
  expect_equal(fs::path_dir(x), as.character(path_temp()))
})
