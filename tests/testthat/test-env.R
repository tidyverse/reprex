test_that("can't see environment of caller", {
  skip_on_cran()
  z <- "don't touch me"
  ret <- reprex(z)
  expect_match(ret, "object 'z' not found", all = FALSE)
})

test_that("reprex doesn't write into environment of caller", {
  skip_on_cran()
  z <- "don't touch me"
  ret <- reprex((z <- "I touched it!"), advertise = FALSE)
  expect_identical(ret[3], "#> [1] \"I touched it!\"")
  expect_identical(z, "don't touch me")

  ## concrete example I have suffered from:
  ## assign object to name of object inside reprex_impl()
  expect_match(reprex(r_file <- 0L), "r_file <- 0L", all = FALSE)
})

test_that("I understand exactly what I'm putting in reprex env", {
  skip_on_cran()
  # https://github.com/r-lib/debugme/issues/50
  pkg <- "debugme"
  skip_if(
    requireNamespace(pkg, quietly = TRUE),
    "styler --> tibble --> pillar --> debugme --> .Random.seed thing"
  )

  ret <- reprex(input = c("a <- 'a'", "ls(all.names = TRUE)"))
  ret <- ret[grepl("^#>", ret)]
  expect_identical(ret, "#> [1] \"a\"")
})
