# nocov start

#' Venue-specific shortcuts
#'
#' These are thin wrappers around `reprex()` that incorporate the target `venue`
#' as a suffix in the function name, for easier access via auto-completion.
#'
#' @param ... Passed along to [reprex()].
#'
#' @name reprex_venue
NULL

#' @export
#' @rdname reprex_venue
reprex_html <- function(...) reprex(..., venue = "html")

#' @export
#' @rdname reprex_venue
reprex_r <- function(...) reprex(..., venue = "r")

#' @export
#' @rdname reprex_venue
reprex_rtf <- function(...) reprex(..., venue = "rtf")

# these should exist for completeness, but I predict they'd never get used and
# they just clutter the auto-complete landscape
# reprex_gh <- function(...) reprex(..., venue = "gh")
# reprex_so <- function(...) reprex(..., venue = "so")
# reprex_ds <- function(...) reprex(..., venue = "ds")

# nocov ends
