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
