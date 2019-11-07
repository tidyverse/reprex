expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

# 1. creates a subdirectory within session temp
# 2. makes that the current working directory
# 3. schedules these cleanup actions for when env goes out of scope:
#    - restore original working directory
#    - delete the directory
# BUT also works when called in the Console, for interactive development joy
scoped_temporary_wd <- function(pattern = "reprextests",
                                env = parent.frame()) {
  tmp <- fs::dir_create(fs::file_temp(pattern))

  # Can't schedule deferred events if calling this from the R console, which
  # is useful when developing tests
  if (identical(env, globalenv())) {
    message("Switching to a temporary working directory!")
    message("Manually restore wd: setwd(rstudioapi::getActiveProject())")
    setwd(tmp)
  } else {
    withr::local_dir(tmp, .local_envir = env)
    withr::defer(dir_delete(tmp), envir = env)
  }
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
