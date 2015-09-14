context("clipboard")

# save original clipboard text so it can be restored at end of tests
# (of course, happens only if cb_ functions work, that's the risk we take)
original <- clipr::read_clip()

test_that("Writing to, reading from, and clearing the clipboard work", {
  # technically we don't know it was copied to clipboard as opposed to
  # stored another way; best we can do
  clipr::write_clip("test clipboard string")
  expect_equal(clipr::read_clip(), "test clipboard string")

  cb_clear()
  expect_warning(ret <- clipr::read_clip())
  expect_equal(length(ret), 0)
})

context("reprex")

test_that("The reprex function with clipboard returns a knitr-d output", {
  clipr::write_clip("y <- 1:4\nmean(y)")
  ret <- reprex(show = FALSE)

  # check it was copied to clipboard
  expect_identical(clipr::read_clip(), ret)

  expect_is(ret, "character")
  expect_true(length(ret) > 0)
  expect_match(ret[1], "```")
  expect_match(ret[2], "y <-")
})


test_that("The reprex function from an expression returns a knitr-d output", {
  ret <- reprex({
    y <- 1:4
    mean(y)
  }, show = FALSE)

  # check it was copied to clipboard
  expect_identical(clipr::read_clip(), ret)

  expect_is(ret, "character")
  expect_true(length(ret) > 0)
  expect_match(ret[1], "```")
  expect_match(ret[2], "y <-")
})

test_that("The reprex is executed in its own environment", {

  z <- "don't touch me"
  ret <- reprex({
    print(paste0(z, "!!!"))
  }, show = FALSE)
  expect_match(ret, "object 'z' not found", all = FALSE)

  ret <- reprex({
    (z <- "I touched it")
  }, show = FALSE)
  expect_identical(z, "don't touch me")

  ## we assign to r_file because if rendering affect caller's environment, this
  ## will break reprex_()
  expect_match(reprex(r_file <- 0L, show = FALSE), "r_file <- 0L", all = FALSE)

})

test_that("The si = TRUE option adds session info line", {
  ret <- reprex({y <- 2}, show = FALSE, si = TRUE)

  expect_true(any(ret %in% c("devtools::session_info()", "sessionInfo()")))
})

test_that("Circular use is detected before render", {
  ret <- reprex({y <- 2}, show = FALSE)
  expect_error(reprex(show = FALSE), "isn't valid R code")
})

test_that("We catch error from rendering garbage input", {
  clipr::write_clip(
    "It really is hard to anticipate just how silly users can be.")
  expect_error(reprex(show = FALSE), "Cannot render this code.")
})

# put original back
clipr::write_clip(original)

