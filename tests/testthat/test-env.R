context("environments")

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
