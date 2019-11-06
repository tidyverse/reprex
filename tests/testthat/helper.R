expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

## set wd to session temp dir, execute testing code, restore previous wd
temporarily <- function(env = parent.frame()) {
  withr::local_dir(path_temp(), .local_envir = env)
}

## useful during interactive test development to toggle the
## rlang_interactive escape hatch
interactive_mode <- function() {
  before <- getOption("rlang_interactive", default = TRUE)
  after <- if (before) FALSE else TRUE
  options(rlang_interactive = after)
  cat("rlang_interactive:", before, "-->", after, "\n")
  invisible()
}
