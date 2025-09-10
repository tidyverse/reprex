# Work around some bug in R.cache and/or styler that affects CI ----
# 2024-01: Since this went in, I have seen yet another CI failure due to what I
# assume is this directory not existing, presumably because some code in styler
# deleted it, after we created it here.
# The problem seemed to go away upon further investigation, so it seems
# somewhat stochastic.
# See https://github.com/tidyverse/reprex/pull/455.
# If we have to debug this again, these are some thoughts:
# * When we forcibly create the directory, also put a file in it. That might
#   keep styler from deleting it.
# * Figure out how to deactivate all styler caching for reprex, at least on CI.
#   Seems to require `options(styler.cache_name = NULL)`.
if (getRversion() >= "4.0.0" && identical(Sys.getenv("CI"), "true")) {
  dir.create(
    tools::R_user_dir("R.cache", which = "cache"),
    recursive = TRUE,
    showWarnings = FALSE
  )
}

expect_messages_to_include <- function(haystack, needles) {
  lapply(
    needles,
    function(x) expect_match(haystack, x, all = FALSE)
  )
  invisible()
}

# 1. creates a subdirectory within session temp
# 2. makes that the current working directory
# 3. schedules these cleanup actions for when env goes out of scope:
#    - restore original working directory
#    - delete the directory
local_temp_wd <- function(pattern = "reprextests", env = parent.frame()) {
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
