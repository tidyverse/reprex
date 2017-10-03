#' Consult an option, then default
#'
#' Arguments that appear like so in the usage:
#' ```
#' f(..., arg = optionally(DEFAULT), ...)
#' ```
#' get their value according to this logic:
#' ```
#' user-specified value or, if not given,
#'   getOption("pkg.arg") or if does not exist,
#'     DEFAULT
#' ```
#' The user can provide a value in the call. Otherwise, an option is consulted.
#' If that does not exist, then the documented default is used. This is not an
#' exported function and should not be called directly.
#'
#' @name optionally
NULL

optionally <- function(default) default

resolve <- function(nm) {
  cl <- sys.call(-1)
  f <- sys.function(-1)
  formal <- formals(f)
  actual <- as.list(match.call(f, cl))
  eval(actual[[nm]]) %||% getOption(nm) %||% eval(formal[[nm]])
}

