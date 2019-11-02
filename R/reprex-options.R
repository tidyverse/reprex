#' reprex options
#'
#' @description
#' Some [reprex()] behaviour can be controlled via an option, providing a way
#' for the user to set personal defaults. The pattern for option names is
#' `reprex.<arg>`, where `<arg>` is an argument of [reprex()]. Here are the main
#' ones:
#'   * `reprex.advertise`
#'   * `reprex.si`
#'   * `reprex.style`
#'   * `reprex.show`
#'   * `reprex.comment`
#'   * `reprex.tidyverse_quiet`
#'   * `reprex.std_out_err`
#'
#' A few more options exist, but are only consulted in specific situations:
#'   * `reprex.venue`: Only consulted by [reprex_selection()]. [reprex()]
#'     itself reveals the possible values for `venue` in the "Usage" section
#'     of its help file and defaults to the first value, in the usual
#'     [match.arg()] way.
#'   * `reprex.highlight.hl_style`: Only relevant to `venue = "rtf`. Details are
#'     in the article
#'     [reprex venue RTF](https://reprex.tidyverse.org/articles/articles/rtf.html).
#'   * `reprex.highlight.font`: See above.
#'   * `reprex.highlight.font_size`: See above.
#'   * `reprex.highlight.other`: See above.
#'
#' Here's code you could put in `.Rprofile` to set reprex options. It would be
#' rare to want non-default behaviour for all of these! We only do so here for
#' the sake of exposition:
#' ```
#' options(
#'   reprex.advertise       = FALSE,
#'   reprex.si              = TRUE,
#'   reprex.style           = TRUE,
#'   reprex.show            = FALSE,
#'   reprex.comment         = "#;-)",
#'   reprex.tidyverse_quiet = FALSE,
#'   reprex.std_out_err     = TRUE,
#'   reprex.venue           = "html", # NOTE: only affects reprex_selection()!
#'   reprex.highlight.hl_style  = "darkbone", # NOTE: only affects RTF venue
#'   reprex.highlight.font      = "Courier",
#'   reprex.highlight.font_size = 35,
#'   reprex.highlight.other     = "--line-numbers"
#' )
#' ```
#' The function `usethis::edit_r_profile()` is handy for creating and/or opening
#' your `.Rprofile`.
#'
#' @section Explaining the `opt()` helper:
#' Arguments that appear like so in [reprex()]:
#' ```
#' reprex(..., arg = opt(DEFAULT), ...)
#' ````
#' get their value according to this logic:
#' ```
#' user-specified value or, if not given,
#'   getOption("reprex.arg") or, if does not exist,
#'     DEFAULT
#' ```
#' It's shorthand for:
#' ```
#' f(..., arg = getOption("reprex.arg", DEFAULT), ...)
#' ```
#' This is not an exported function and should not be called directly.
#'
#' @name reprex_options
#' @aliases opt
NULL

optionally <- function(x, opt_name = NA_character_) {
  if (!is.na(opt_name)) {
    attr(x, "opt_name") <- opt_name
  }
  attr(x, "optional") <- TRUE
  x
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

de_opt <- function(x) {
  attr(x, "optional") <- NULL
  attr(x, "opt_name") <- NULL
  x
}

make_opt_name <- function(x) {
  pkg_name <- tryCatch(ns_env_name(), error = function(e) NULL)
  paste(c(pkg_name, x), collapse = ".")
}
