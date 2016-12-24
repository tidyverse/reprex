context("reprex")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

test_that("clipboard input works", {
  skip_if_no_clipboard()
  clipr::write_clip("1:5")
  ret <- reprex(show = FALSE)
  expect_identical(ret, out)
})

test_that("expression input works", {
  ret <- reprex(1:5, show = FALSE)
  expect_identical(ret, out)
})

test_that("file input works", {
  write("1:5", "foo.R")
  ret <- reprex(infile = "foo.R", show = FALSE)
  expect_identical(ret, out)
  file.remove("foo.R")
})

test_that("can't see environment of caller", {
  z <- "don't touch me"
  ret <- reprex(z, show = FALSE)
  expect_match(ret, "object 'z' not found", all = FALSE)
})

test_that("reprex doesn't write into environment of caller", {
  z <- "don't touch me"
  ret <- reprex((z <- "I touched it!"), show = FALSE)
  expect_identical(ret[3], "#> [1] \"I touched it!\"")
  expect_identical(z, "don't touch me")

  ## concrete example I have suffered from:
  ## assign object to name of object inside reprex_()
  expect_match(reprex(r_file <- 0L, show = FALSE), "r_file <- 0L", all = FALSE)

})

test_that("I understand exactly what I'm putting in reprex env", {
  ret <- reprex(ls(all.names = TRUE), show = FALSE)
  out <- c("``` r", "ls(all.names = TRUE)", "#> [1] \".input\"", "```")
  expect_identical(ret, out)
})

test_that("Circular use is detected before render", {
  ret <- reprex(y <- 2, show = FALSE)
  write(ret, "foo.md")
  expect_error(reprex(infile = "foo.md", show = FALSE), "isn't valid R code")
  file.remove("foo.md")
})

test_that("reprex is written to outfile", {
  ret <- reprex("1:5", show = FALSE, outfile = "foo")
  expect_identical(ret, readLines("foo.md"))
  expect_match(tail(readLines("foo.R"), 1), "\"1:5\"")
  file.remove("foo.R", "foo.md")

  ## make sure `.md` extension gets stripped
  ret <- reprex("1:5", show = FALSE, outfile = "foo.md")
  expect_identical(ret, readLines("foo.md"))
  file.remove("foo.R", "foo.md")
})
