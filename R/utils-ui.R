reprex_quiet <- function() {
  as.logical(Sys.getenv("REPREX_QUIET", unset = "NA"))
}

local_reprex_quiet <- function(reprex_quiet = "TRUE", env = parent.frame()) {
  withr::local_envvar(c(REPREX_QUIET = reprex_quiet), .local_envir = env)
}

local_reprex_loud <- function(env = parent.frame()) {
  local_reprex_quiet("FALSE", env = env)
}

reprex_alert <- function(text,
                         type = c("success", "info", "warning", "danger"),
                         .envir = parent.frame()) {
  quiet <- reprex_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  cli_fun <- switch(
    type,
    success = cli::cli_alert_success,
    info    = cli::cli_alert_info,
    warning = cli::cli_alert_warning,
    danger  = cli::cli_alert_danger,
    cli::cli_alert
  )
  cli_fun(text = text, wrap = TRUE, .envir = .envir)
}

reprex_success <- function(text, .envir = parent.frame()) {
  reprex_alert(text, type = "success", .envir = .envir)
}

reprex_info <- function(text, .envir = parent.frame()) {
  reprex_alert(text, type = "info", .envir = .envir)
}

reprex_warning <- function(text, .envir = parent.frame()) {
  reprex_alert(text, type = "warning", .envir = .envir)
}

reprex_danger <- function(text, .envir = parent.frame()) {
  reprex_alert(text, type = "danger", .envir = .envir)
}

# TODO: if a better built-in solution arises in the semantic UI, use it
# https://github.com/r-lib/cli/issues/211
reprex_path <- function(header, path, type = "success", .envir = parent.frame()) {
  quiet <- reprex_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  reprex_alert(header, type = type, .envir = .envir)
  cli::cli_div(theme = list(.alert = list(`margin-left` = 2, before = "")))
  cli::cli_alert("{.path {path}}")
  cli::cli_end()
}

message <- function(...) {
  abort("Internal error: use reprex's UI functions, not `message()`")
}
