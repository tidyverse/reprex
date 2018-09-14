context("input")

out <- c("``` r", "1:5", "#> [1] 1 2 3 4 5", "```")

exp_msg <- switch(
  as.character(clipboard_available()),
  `TRUE` = "Rendered reprex is on the clipboard.",
  "Unable to put result on the clipboard"
)

test_that("reprex: clipboard input works", {
  skip_on_cran()
  skip_if_no_clipboard()
  clipr::write_clip("1:5")
  expect_match(reprex(render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: expression input works", {
  skip_on_cran()
  expect_match(reprex(1:5, render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: character input works", {
  skip_on_cran()
  expect_match(reprex(input = "1:5\n", render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: file input works", {
  skip_on_cran()
  temporarily()
  withr::local_file("foo.R")
  write("1:5", "foo.R")
  expect_match(reprex(input = "foo.R", render = FALSE), "^1:5$", all = FALSE)
})

test_that("reprex: file input in a subdirectory works", {
  skip_on_cran()
  temporarily()
  withr::defer(dir_delete("foo"))
  dir_create("foo")
  write("1:5", path("foo", "foo.R"))
  expect_match(
    reprex(input = path("foo", "foo.R"), render = FALSE),
    "^1:5$",
    all = FALSE
  )
})

test_that("Circular use is detected before source file written", {
  skip_on_cran()
  ret <- reprex(y <- 2, venue = "gh", show = FALSE)
  expect_error(reprex(input = ret, render = FALSE), "Aborting")
  ret <- reprex(y <- 2, venue = "so", show = FALSE)
  expect_error(reprex(input = ret, render = FALSE), "Aborting")
})

test_that("Leading prompts are removed", {
  skip_on_cran()
  input <- c("x <- 1:3", "median(x)")
  res <- reprex(input = input, render = FALSE)
  input2 <- paste0(getOption("prompt"), input)
  expect_message(
    res2 <- reprex(input = input2, render = FALSE),
    "Removing leading prompts"
  )
  expect_identical(res, res2)
})

test_that("newlines in code are protected and uniformly so across venues", {
  skip_on_cran()
  ## NOTE: use of single vs double quotes is counter-intuitive, but deliberate
  input <- 'paste(letters[1:3], collapse = "\n")\n'
  chr_input <- reprex(input = input, render = FALSE)

  input_file <- path_temp("foo.R")
  withr::local_file(input_file)
  writeLines(
    escape_newlines('paste(letters[1:3], collapse = "\n")'),
    input_file
  )
  path_input <- reprex(input = input_file, render = FALSE)

  expr_input <- reprex(paste(letters[1:3], collapse = "\n"), render = FALSE)

  expect_identical(chr_input, path_input)
  expect_identical(chr_input, expr_input)
})
