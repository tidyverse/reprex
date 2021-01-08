reprex_quiet <- function() {
  as.logical(Sys.getenv("REPREX_QUIET", unset = "NA"))
}

local_reprex_quiet <- function(reprex_quiet, env = parent.frame()) {
  withr::local_envvar(c(REPREX_QUIET = reprex_quiet), .local_envir = env)
}

reprex_inform <- function(message) {
  quiet <- reprex_quiet() %|% is_testing()
  if (quiet) {
    invisible()
  } else {
    inform(message, class = "reprex_message")
  }
}



message <- function(...) {
  stop("Internal error: use reprex_inform() instead of message()")
}
