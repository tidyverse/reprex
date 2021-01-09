reprex_quiet <- function() {
  as.logical(Sys.getenv("REPREX_QUIET", unset = "NA"))
}

local_reprex_quiet <- function(reprex_quiet, env = parent.frame()) {
  withr::local_envvar(c(REPREX_QUIET = reprex_quiet), .local_envir = env)
}

local_reprex_loud <- function(env = parent.frame()) {
  local_reprex_quiet("FALSE", env = env)
}

reprex_inform <- function(message, .env = parent.frame()) {
  quiet <- reprex_quiet() %|% is_testing()
  if (quiet) {
    invisible()
  } else {
    g <- function(x) glue::glue(x, .envir = .env)
    message <- map_chr(message, g)
    inform(message, class = "reprex_message")
  }
}

message <- function(...) {
  abort("Internal error: use `reprex_inform()` instead of `message()`")
}

map_chr <- function(.x, .f, ...) {
  out <- vapply(.x, .f, character(1), ..., USE.NAMES = FALSE)
  names(out) <- names(.x)
  out
}
