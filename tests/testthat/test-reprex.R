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
  expect_equal(length(clipr::read_clip()), 0)
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

test_that("The session_info = TRUE option adds session info line", {
  ret <- reprex({y <- 2}, show = FALSE, session_info = TRUE)

  expect_true(any(ret %in% c("devtools::session_info()", "sessionInfo()")))
})


# put original back
clipr::write_clip(original)

