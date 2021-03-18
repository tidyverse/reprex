test_that("venue = 'gh' works with/without leading prose", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "Hello world",
    "",
    "``` r",
    "## comment",
    "1:5",
    "#> [1] 1 2 3 4 5",
    "```"
  )
  ret <- reprex(input = input, venue = "gh", advertise = FALSE)
  expect_identical(ret, output)

  input <- grep("Hello", input, invert = TRUE, value = TRUE)
  output <- grep("Hello", output, invert = TRUE, value = TRUE)
  output <- output[nzchar(output)]
  ret <- reprex(input = input, venue = "gh", advertise = FALSE)
  expect_identical(ret, output)
})

test_that("venue = 'R' works, regardless of case", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "#' Hello world",
    "## comment",
    "1:5",
    "#> [1] 1 2 3 4 5"
  )
  ret <- reprex(input = input, venue = "R", advertise = FALSE)
  expect_identical(ret[nzchar(ret)], output)
  ret <- reprex(input = input, venue = "r", advertise = FALSE)
  expect_identical(ret[nzchar(ret)], output)
})

test_that("venues = 'ds' and 'so' are aliases for 'gh'", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  ds <- reprex(input = input, venue = "ds", session_info = TRUE, advertise = FALSE)
  so <- reprex(input = input, venue = "so", session_info = TRUE, advertise = FALSE)
  gh <- reprex(input = input, venue = "gh", session_info = TRUE, advertise = FALSE)
  expect_identical(so, gh)
  expect_identical(ds, gh)
})

test_that("local image link is not interrupted by hard line break for 'gh'", {
  skip_on_cran()
  input <- c(
    "#+ setup, include = FALSE",
    "knitr::opts_knit$set(upload.fun = identity)",
    "",
    "#+ incredibly-long-chunk-name-to-make-image-path-also-incredibly-long",
    "plot(1:3)"
  )
  out <- reprex(input = input, venue = "gh")
  i <- grep("incredibly-long", out)
  expect_true(grepl("[)]", out[i]))
})

test_that("venue = 'html' works", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "<head>",
    "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">",
    "</head>",
    "<p>Hello world</p>",
    "<pre class=\"r\"><code>## comment",
    "1:5",
    "#&gt; [1] 1 2 3 4 5</code></pre>"
  )
  ret <- reprex(input = input, venue = "html", advertise = FALSE)
  ret <- ret[nzchar(ret)]
  expect_identical(ret, output)
})

test_that("venue = 'slack' works", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5"
  )
  output <- c(
    "Hello world",
    "```",
    "## comment",
    "1:5",
    "#> [1] 1 2 3 4 5",
    "```"
  )
  ret <- reprex(input = input, venue = "slack")
  ret <- ret[nzchar(ret)]
  expect_identical(ret, output)
})

test_that("venue = 'bb' works", {
  skip_on_cran()
  input <- c(
    "#' Hello world",
    "## comment",
    "1:5",
    "#' Next is _italic_ or **bold** or even __*bold italic*__"
  )
  output <- c(
    "Hello world",
    "[code=php]",
    "## comment",
    "1:5",
    "#> [1] 1 2 3 4 5",
    "[/code]",
    "Next is [i]italic[/i] or [b]bold[/b] or even [i][b]bold italic[/b][/i]"
  )
  ret <- reprex(input = input, venue = "bb")
  ret <- ret[nzchar(ret)]
  expect_identical(ret, output)
})
