test_that("expected outfiles are written and messaged, venue = 'gh'", {
  skip_on_cran()
  local_temp_wd()
  local_reprex_loud()

  msg <- trimws(capture_messages(
    ret <- reprex(1:5, wd = ".")
  ))

  outfiles <- dir_ls()
  expect_setequal(
    gsub("[a-z-]+(_reprex.+)", "\\1", outfiles),
    c("_reprex.R", "_reprex.md")
  )
  r_file <- grep("_reprex[.]R", outfiles, value = TRUE)
  expect_match(read_lines(r_file), "1:5", all = FALSE)
  md_file <- grep("_reprex[.]md", outfiles, value = TRUE)
  expect_equal(ret, read_lines(md_file))

  expect_messages_to_include(
    msg,
    c("Preparing reprex as .*.R.* file", "Writing reprex file", outfiles)
  )
})

test_that("expected outfiles are written and messaged, venue = 'R'", {
  skip_on_cran()
  local_temp_wd()
  local_reprex_loud()

  msg <- trimws(capture_messages(
    ret <- reprex(1:5, wd = ".", venue = "R")
  ))

  outfiles <- dir_ls()
  expect_setequal(
    gsub("[a-z-]+(_reprex.+)", "\\1", outfiles),
    c("_reprex.R", "_reprex.md", "_reprex_r.R")
  )
  rout_file <- grep("_reprex_r[.]R", outfiles, value = TRUE)
  expect_equal(ret, read_lines(rout_file))

  expect_messages_to_include(
    msg,
    c("Preparing reprex as .*R.* file", "Writing reprex file", rout_file)
  )
})

test_that("expected outfiles are written and messaged, venue = 'html'", {
  skip_on_cran()
  local_temp_wd()
  local_reprex_loud()

  msg <- trimws(capture_messages(
    ret <- reprex(1:5, wd = ".", venue = "html")
  ))

  outfiles <- dir_ls()
  # punting on the issue of the `utf8.md` file and folder of files
  expect_true(all(
    c("_reprex.R", "_reprex.md", "_reprex.html") %in%
      gsub("[a-z-]+(_reprex.+)", "\\1", outfiles)
  ))
  html_file <- grep("_reprex[.]html", outfiles, value = TRUE)
  expect_equal(ret, read_lines(html_file))

  expect_messages_to_include(
    msg,
    c("Preparing reprex as .*R.* file", "Writing reprex file", html_file)
  )
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
