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

## wrap clipr::clipr_available() so I can mock it
clipboard_available <- function() {
  if (Sys.getenv("CLIPBOARD_AVAILABLE", unset = TRUE)) {
    return(clipr::clipr_available())
  }
  FALSE
}

strip_ext <- function(x, ext = "md|r|html") {
  if (is.null(x)) return(NULL)
  if (grepl(ext, tolower(tools::file_ext(x)))) {
    tools::file_path_sans_ext(x)
  } else {
    x
  }
}

add_suffix <- function(x, suffix = "") {
  paste(x, suffix, sep = "_")
}

add_ext <- function(x, ext = "R", force = FALSE) {
  lacks_ext <- !grepl(ext, toupper(tools::file_ext(x)))
  if (lacks_ext || force) {
    paste(x, ext, sep = ".")
  } else {
    x
  }
}

newlined <- function(x) {
  if (!grepl("\n$", x[[length(x)]])) {
    x[[length(x)]] <- paste0(x[[length(x)]], "\n")
  }
  x
}
