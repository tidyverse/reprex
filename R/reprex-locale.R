#' Render a reprex in a different locale
#'
#' @description
#' Render a [reprex()] using a different locale.
#'
#' @param ... Parameters passed onto [reprex()].
#' @param locale String. The locale to be used when rendering the [reprex()].
#'
#' @return Character vector of rendered reprex, invisibly.
#' @examples
#' \dontrun{
#' # Rendering in Italian:
#' reprex_locale({
#'   dplyr::select(foo)
#' }, locale = "it_IT")
#'
#' # Rendering in Spanish:
#' reprex_locale({
#'   df <- data.frame(
#'     stringsAsFactors = FALSE,
#'     date = as.Date(c("2019-01-01", "2019-02-01")),
#'     value = c(1, 2)
#'   )
#'   plot(df$date, df$value)
#' }, locale = "es_ES")
#' }
#'
#' @export
reprex_locale <- function(..., locale) {
  withr::local_envvar(c("LANG" = locale))
  withr::local_locale(c("LC_MESSAGES" = locale))
  reprex(...)
}
