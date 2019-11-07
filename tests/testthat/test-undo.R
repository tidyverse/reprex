## intentionally forcing continuation lines
input <- c(
  "## a comment",
  "x <- 1:4",
  "#' hi",
  "y <- c(2,",
  "  3, 4,",
  "  5)",
  "x + y"
)

test_that("round trip, venue = 'gh': reprex() --> reprex_invert()", {
  skip_on_cran()
  output <- reprex(input = input, advertise = FALSE)
  res <- reprex_invert(output)
  expect_identical(input, res[nzchar(res)])
})

test_that("round trip, venue = 'r': reprex() --> reprex_invert()", {
  skip_on_cran()
  output <- reprex(input = input, advertise = FALSE, venue = "r")
  res <- reprex_clean(output)
  expect_identical(input, res[nzchar(res)])
})

test_that("reprex_rescue() rescues code from R Console copy/paste", {
  skip_on_cran()
  console <- c(
    "> ## a regular comment, which is retained",
    "> (y <- c(2,",
    "+         3, 4,",
    "+         5))",
    "[1] 2 3 4 5",
    "> median(y)",
    "[1] 3.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(y <- c(2,",
    "        3, 4,",
    "        5))",
    "median(y)"
  )
  expect_identical(reprex_rescue(console), output)
})

test_that("reprex_rescue()'s prompt argument works", {
  skip_on_cran()
  code <- c(
    ":-) ## a regular comment, which is retained",
    ":-) (x <- 1:4)",
    "[1] 1 2 3 4",
    ":-) median(x)",
    "[1] 2.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(x <- 1:4)",
    "median(x)"
  )
  expect_identical(reprex_rescue(code, prompt = ":-) "), output)
})

test_that("reprex_rescue()'s continue argument works", {
  skip_on_cran()
  code <- c(
    "> ## a regular comment, which is retained",
    "> (y <- c(2,",
    "yes, and?         3, 4,",
    "yes, and?         5))",
    "[1] 2 3 4 5",
    "> median(y)",
    "[1] 3.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(y <- c(2,",
    "        3, 4,",
    "        5))",
    "median(y)"
  )
  expect_identical(reprex_rescue(code, continue = "yes, and? "), output)
})

test_that("reprex_rescue() can cope with leading whitespace", {
  skip_on_cran()
  console <- c(
    "> ## a regular comment, which is retained",
    " > (x <- 1:4)",
    "   [1] 1 2 3 4",
    "   > median(x)",
    "2.5"
  )
  output <- c(
    "## a regular comment, which is retained",
    "(x <- 1:4)",
    "median(x)"
  )
  expect_identical(reprex_rescue(console), output)
})

test_that("reprex_invert() can write to specific outfile", {
  skip_on_cran()
  scoped_temporary_wd()

  code <- c("x <- 1:3", "median(x)")
  invert_me <- reprex(input = code, advertise = FALSE)
  out <- reprex_invert(input = invert_me, outfile = "foo")
  expect_identical(read_lines("foo_clean.R"), out)
})

test_that("reprex_invert() can name its own outfile", {
  skip_on_cran()
  scoped_temporary_wd()

  code <- c("x <- 1:3", "median(x)")
  invert_me <- reprex(input = code, advertise = FALSE)
  msg <- capture_messages(
    out <- reprex_invert(input = invert_me, outfile = NA)
  )
  msg <- sub("\n$", "", msg)
  outfile <- regmatches(msg, regexpr("reprex(.*)", msg))
  expect_identical(read_lines(outfile), out)
})

test_that("reprex_invert() can name outfile based on input filepath", {
  skip_on_cran()
  scoped_temporary_wd()

  code <- c("x <- 1:3", "median(x)")
  reprex(input = code, advertise = FALSE, outfile = "a")
  out <- reprex_invert(input = "a_reprex.md", outfile = NA)
  expect_identical(read_lines("a_reprex_clean.R"), out)
})

test_that("reprex_invert(venue = 'gh') doesn't strip leading ws", {
  skip_on_cran()
  scoped_temporary_wd()

  input <- c("head(", "    letters)")
  reprexed <- reprex(
    input = input, venue = "gh", advertise = FALSE
  )
  inverted <- reprex_invert(reprexed, venue = "gh")
  expect_match(inverted, input[2], all = FALSE, fixed = TRUE)
})
