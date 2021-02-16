test_that("expected outfiles are written and messaged, venue = 'gh'", {
  skip_on_cran()
  local_temp_wd()
  local_reprex_loud()

  msg <- trimws(capture_messages(
    ret <- reprex(1:5, wd = ".")
  ))
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .*.R.* file", "_reprex.R$",
      "Writing reprex file", "_reprex.md$"
    )
  )
  r_file <- grep("_reprex.R$", msg, value = TRUE)
  expect_match(read_lines(r_file), "1:5", all = FALSE)
  md_file <- grep("_reprex.md$", msg, value = TRUE)
  expect_equal(ret, read_lines(md_file))
})

test_that("expected outfiles are written and messaged, venue = 'R'", {
  skip_on_cran()
  local_temp_wd()
  local_reprex_loud()

  msg <- trimws(capture_messages(
    ret <- reprex(1:5, wd = ".", venue = "R")
  ))
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .*R.* file", "_reprex.R",
      "Writing reprex file", "_reprex_rendered.R"
    )
  )
  r_file <- grep("_reprex.R$", msg, value = TRUE)
  expect_match(read_lines(r_file), "1:5", all = FALSE)
  rout_file <- grep("_reprex_rendered.R$", msg, value = TRUE)
  expect_equal(ret, read_lines(rout_file))
})

test_that(".R outfile doesn't clobber .R infile", {
  skip_on_cran()
  local_temp_wd()

  write_lines("1:5", "foo.R")
  ret <- reprex(input = "foo.R")
  expect_identical("1:5", read_lines("foo.R"))
})

test_that("infile can have path components", {
  skip_on_cran()
  local_temp_wd()
  local_reprex_loud()

  dir_create("aaa")
  write_lines("1:5", "aaa/bbb.R")
  msg <- capture_messages(
    ret <- reprex(input = "aaa/bbb.R")
  )
  expect_messages_to_include(
    msg,
    c("Preparing reprex as .*.R.* file", "aaa/bbb_reprex.R",
      "Writing reprex file", "aaa/bbb_reprex.md"
    )
  )
})

test_that("pre-existing xyz_reprex.R doesn't get clobbered w/o user's OK", {
  skip_on_cran()
  local_temp_wd()

  write_lines("5:1", "xyz.R")
  ret <- reprex(input = "xyz.R")
  expect_match(read_lines("xyz_reprex.md"), "5:1", all = FALSE, fixed = TRUE)
  write_lines("max(4:6)", "xyz.R")
  reprex(input = "xyz.R")
  expect_match(read_lines("xyz_reprex.md"), "5:1", all = FALSE, fixed = TRUE)
})
