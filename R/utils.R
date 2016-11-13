read_from_template <- function(SLUG) {
  SLUG_path <-
    system.file("templates", paste0(SLUG, ".R"), package = "reprex")
  readLines(SLUG_path)
}

## from purrr, among other places
`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

## deparse that turns NULL into "" instead of "NULL"
deparse2 <- function(expr, ...) {
  if (is.null(expr)) return("")
  deparse(expr, ...)
}

prep_opts <- function(txt, which = "chunk") {
  txt <- deparse2(txt)
  setter <- paste0("knitr::opts_", which, "$set")
  sub("^list", setter, txt)
}

## if input was expression AND formatR is available, tidy the code
## leading whitespace will have been stripped inside stringify_expression()
prep_tidy <- function(expr_input) {
  expr_input && requireNamespace("formatR", quietly = TRUE)
}

trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}
