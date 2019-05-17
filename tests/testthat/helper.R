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

## useful during interactive test development to toggle the
## rlang_interactive escape hatch in reprex:::interactive()
interactive_mode <- function() {
  before <- getOption("rlang_interactive", default = TRUE)
  after <- if (before) FALSE else TRUE
  options(rlang_interactive = after)
  cat("rlang_interactive:", before, "-->", after, "\n")
  invisible()
}
