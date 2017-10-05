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

arg_option <- function(arg) {
  arg_expr <- enexpr(arg)
  if (!is_symbol(arg_expr)) {
    abort("Internal error: `arg_option()` expects a symbol")
  }

  arg_nm <- as_string(arg_expr)
  opt_nm <- paste(ns_env_name(), arg_nm, sep = ".")

  cl <- call_frame(2)
  fn <- caller_fn()
  formal <- fn_fmls(fn)[[arg_nm]]
  actual <- as.list(lang_standardise(cl))[[arg_nm]]

  eval_bare(actual, get_env(cl)) %||%
    getOption(opt_nm) %||%
    eval_bare(formal, get_env(fn))
}
