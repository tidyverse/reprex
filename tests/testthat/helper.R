expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

# 1. creates a subdirectory within session temp
# 2. makes that the current working directory
# 3. schedules these cleanup actions for when env goes out of scope:
#    - restore original working directory
#    - delete the directory
local_temp_wd <- function(pattern = "reprextests",
                          env = parent.frame()) {

  tmp <- withr::local_tempdir(pattern = pattern, .local_envir = env)
  withr::local_dir(tmp, .local_envir = env)
  invisible(tmp)
}

# based on advice from Hadley:
# "I don't know what causes an app to start and stop, but if it's started
# before the tests begin running, it'll pick up the wrong values and then
# hold on to them for the rest of the sequence"
#
# otherwise, unicode and ANSI colours are impossible to suppress in
# saved snapshots
# the current values of options `crayon.enabled` and `cli.unicode`, both of
# which are set to FALSE by test_that(), have no effect
#
# presumably this will get addressed upstream, in testthat and/or cli, but not
# before I want to release
local_cli_app <- function(env = parent.frame()) {
  cli::start_app(.auto_close = TRUE, .envir = env)
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
