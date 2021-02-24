test_that("retrofit_files() works", {
  local_reprex_loud()

  # when `outfile` has the default value, there's nothing to do
  expect_equal(
    retrofit_files(infile = NULL, wd = NULL, outfile = "DEPRECATED"),
    list(infile = NULL, wd = NULL)
  )
  expect_equal(
    retrofit_files(infile = "foo.R", wd = "whatever", outfile = "DEPRECATED"),
    list(infile = "foo.R", wd = "whatever")
  )

  # `wd` takes predence over `outfile` and we say something
  expect_snapshot(
    retrofit_files(wd = "this", outfile = "that")
  )

  # `outfile = NA` morphs into `wd = "."`, if no `infile`
  expect_snapshot(
    retrofit_files(outfile = NA),
  )

  # only `wd` is salvaged from `outfile = some/path/blah` and we mention `input`
  expect_snapshot(
    retrofit_files(outfile = "some/path/blah")
  )

  # `infile` takes over much of `outfile`'s previous role
  expect_snapshot(
    retrofit_files(infile = "a/path/foo.R", outfile = NA)
  )
  expect_snapshot(
    retrofit_files(infile = "a/path/foo.R", outfile = "other/path/blah")
  )
})
