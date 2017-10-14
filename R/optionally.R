#' Consult an option, then default
#'
#' Arguments that appear like so in the usage:
#' ```
#' f(..., arg = opt(DEFAULT), ...)
#' ```
#' get their value according to this logic:
#' ```
#' user-specified value or, if not given,
#'   getOption("reprex.arg") or if does not exist,
#'     DEFAULT
#' ```
#' It's shorthand for:
#' ```
#' f(..., arg = getOption("reprex.arg", DEFAULT), ...)
#' ```
#' This is not an exported function and should not be called directly.
#'
#' Many of the arguments of [reprex()] use `opt()`. If you don't like the
#' official defaults, override them in your `.Rprofile`. Here's an example for
#' someone who dislikes the "Created by ..." string, always wants session info,
#' prefers to restyle their code, uses a winky face comment string, and likes
#' the tidyverse startup message.
#' ```
#' options(
#'   reprex.advertise = FALSE,
#'   reprex.si = TRUE,
#'   reprex.styler = TRUE,
#'   reprex.comment = "#;-)",
#'   reprex.tidyverse_quiet = FALSE
#' )
#' ```
#' @name opt
NULL

optionally <- function(x, opt_name = NA_character_) {
  if (!is.na(opt_name)) {
    x <- set_attrs(x, opt_name = opt_name)
  }
  set_attrs(x, optional = TRUE)
}

opt <- optionally

arg_option <- function(arg) {

  arg_expr <- enexpr(arg)
  if (!is_symbol(arg_expr)) {
    abort("Internal error: `arg_option()` expects a symbol")
  }

  opt_name <- attr(arg, "opt_name") %||% make_opt_name(as_string(arg_expr))

  if (is_optional(arg)) {
    getOption(opt_name) %||% de_opt(arg)
  } else {
    arg
  }
}

is_optional <- function(x) isTRUE(attr(x, "optional"))

de_opt <- function(x) set_attrs(x, optional = NULL, opt_name = NULL)

make_opt_name <- function(x) {
  pkg_name <- tryCatch(ns_env_name(), error = function(e) NULL)
  paste0(c(pkg_name, x), collapse = ".")
}
