expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

with_mock <- function(..., .parent = parent.frame()) {
  mockr::with_mock(..., .parent = .parent, .env = "reprex")
}

# 1. creates a subdirectory within session temp
# 2. makes that the current working directory
# 3. schedules these cleanup actions for when env goes out of scope:
#    - restore original working directory
#    - delete the directory
local_temp_wd <- function(pattern = "reprextests",
                          env = parent.frame()) {

  old_wd <- getwd()
  tmp <- withr::local_tempdir(pattern = pattern, .local_envir = env)
  withr::local_dir(tmp, .local_envir = env)
  reprex_path("Switching to temporary working directory:", tmp)
  withr::defer(
    reprex_path("Restoring original working directory:", old_wd),
    envir = env
  )
  invisible(tmp)
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
