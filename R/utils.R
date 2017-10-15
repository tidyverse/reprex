is_toggle <- function(x) {
  length(x) == 1 && is.logical(x) && !is.na(x)
}

is_path <- function(x) {
  length(x) == 1 && is.character(x) && !grepl("\n$", x)
}

read_lines <- function(path) {
  if (is.null(path)) return(NULL)
  readLines(path)
}

## from purrr, among other places
`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

## deparse that returns NULL for NULL instead of "NULL"
deparse2 <- function(expr, ...) {
  if (is.null(expr)) return(NULL)
  deparse(expr, ...)
}

## dirname that returns "" instead of "."
## e.g., for a file that is in working directory
dirname2 <- function(path) {
  out <- dirname(path)
  if (identical(out, ".")) {
    return("")
  }
  out
}

## switch to a solution based on pathr::rel_path() when/if it goes to CRAN?
## the branch consists of a stem + leaves = a normalized file path
## given the branch and one leaf, what is the stem?
## input:
##    leaf =                         foo.R   (wd = /Users/jenny/rrr/reprex)
##  branch = /Users/jenny/rrr/reprex/foo.md
## output:
##  path_stem(leaf, branch) = "/Users/jenny/rrr/reprex/"
path_stem <- function(leaf, branch) {
  res <- sub(dirname2(leaf), "", dirname(branch))
  if (identical(substr(res, nchar(res), nchar(res)), .Platform$file.sep)) {
    return(res)
  }
  paste0(res, .Platform$file.sep)
}

prep_opts <- function(txt, which = "chunk") {
  txt <- deparse2(txt)
  setter <- paste0("knitr::opts_", which, "$set")
  sub("^list", setter, txt)
}

trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

trim_common_leading_ws <- function(x) {
  m <- regexpr("^(\\s*)", x)
  ws <- regmatches(x, m)
  num <- min(nchar(ws))
  substring(x, num + 1)
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

ingest_input <- function(input = NULL) {

  if (is.null(input)) {                            ## clipboard or bust
    if (clipboard_available()) {
      return(suppressWarnings(clipr::read_clip()))
    } else {
      message("No input provided and clipboard is not available.")
      return(character())
    }
  }

  if (is_path(input)) {                             ## path
    read_lines(input)
  } else {
    escape_newlines(sub("\n$", "", input))          ## vector or string
  }
}

## stripped down version of yesno() from devtools
## returns TRUE if user says "no"
##         FALSE if user says "yes"
yesno <- function(..., yes = "yes", no = "no") {
  if (interactive()) {
    cat(paste0(..., collapse = ""))
    return(utils::menu(c(yes, no)) == 2)
  }
  TRUE
}

escape_regex <- function(x) {
  chars <- c("*", ".", "?", "^", "+", "$", "|", "(", ")", "[", "]", "{", "}", "\\")
  gsub(paste0("([\\", paste0(collapse = "\\", chars), "])"), "\\\\\\1", x, perl = TRUE)
}

escape_newlines <- function(x) {
  gsub("\n", "\\\\n", x, perl = TRUE)
}

in_tests <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

ds_is_gh <- function(venue) {
  if (venue == "ds") {
    message("FYI, the Discourse venue \"ds\" is currently an alias for the ",
            "default GitHub venue \"gh\".\nYou don't need to specify it.")
    venue <- "gh"
  }
  venue
}
