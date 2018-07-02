## used to make clipboard unavailable locally
# Sys.setenv("CLIPBOARD_AVAILABLE" = TRUE)
# Sys.setenv("CLIPBOARD_AVAILABLE" = FALSE)

NOT_CRAN <- Sys.getenv("NOT_CRAN", unset = "")
ON_CRAN <- identical(NOT_CRAN, "") || identical(tolower(NOT_CRAN), "false")
if (ON_CRAN) {
  Sys.setenv("CLIPBOARD_AVAILABLE" = FALSE)
}

skip_if_no_clipboard <- function() {
  if (!clipboard_available()) {
    skip("System clipboard is not available - skipping test.")
  }
  return(invisible(TRUE))
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

## set wd to session temp dir, execute testing code, restore previous wd
temporarily <- function(env = parent.frame()) {
  withr::local_dir(path_temp(), .local_envir = env)
}

## call during interactive test development to fake being "in tests" and thereby
## cause in-house interactive() to return FALSE
test_mode <- function() {
  before <- Sys.getenv("TESTTHAT")
  after <- if (before == "true") "false" else "true"
  Sys.setenv(TESTTHAT = after)
  cat("TESTTHAT:", before, "-->", after, "\n")
  invisible()
}
