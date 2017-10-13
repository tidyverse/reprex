context("input")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

exp_msg <- switch(
  as.character(clipboard_available()),
  `TRUE` = "Rendered reprex is on the clipboard.",
  "Unable to put result on the clipboard"
)

test_that("reprex: clipboard input works", {
  skip_if_no_clipboard()
  clipr::write_clip("1:5")
  expect_match(reprex(render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: expression input works", {
  expect_match(reprex(1:5, render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: character input works", {
  expect_match(reprex(input = "1:5\n", render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: file input works", {
  on.exit(file.remove("foo.R"))
  write("1:5", "foo.R")
  expect_match(reprex(input = "foo.R", render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: file input in a subdirectory works", {
  on.exit(unlink("foo", recursive = TRUE))
  dir.create("foo")
  write("1:5", file.path("foo", "foo.R"))
  expect_match(
    reprex(input = file.path("foo", "foo.R"), render = FALSE),
    "^1:5$",
    all = FALSE
  )
})

test_that("Circular use is detected before source file written", {
  ret <- reprex(y <- 2, venue = "gh", show = FALSE)
  expect_error(reprex(input = ret, render = FALSE), "isn't valid R code")
  ret <- reprex(y <- 2, venue = "so", show = FALSE)
  expect_error(reprex(input = ret, render = FALSE), "isn't valid R code")
})

test_that("Leading prompts are removed", {
  input <- c("x <- 1:3", "median(x)")
  res <- reprex(input = input, render = FALSE)
  input2 <- paste0(getOption("prompt"), input)
  expect_message(
    res2 <- reprex(input = input2, render = FALSE),
    "Removing leading prompts"
  )
  expect_identical(res, res2)
})

test_that("ingest_input() works", {
  input <- c("line 1", "line 2")

  expect_identical(input, ingest_input(input))

  input_collapsed <- paste0(input, "\n", collapse = "")
  expect_identical(input, ingest_input(input_collapsed))

  input_first_elem <- paste0(input[1], "\n")
  expect_identical(input[1], ingest_input(input_first_elem))

  on.exit(file.remove("foo.R"))
  writeLines(input, "foo.R")
  expect_identical(input, ingest_input("foo.R"))
})
