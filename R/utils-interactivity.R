interactive <- function(...) {
  stop("In this house, we use rlang::is_interactive()")
}

## wrap clipr::clipr_available() so I can tweak its behaviour
clipboard_available <- function() {
  if (is_interactive()) {
    clipr::clipr_available()
  } else {
    isTRUE(as.logical(Sys.getenv("CLIPR_ALLOW", FALSE)))
  }
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

## returns TRUE if user says "no"
##         FALSE otherwise
nope <- function(..., yes = "yes", no = "no") {
  if (is_interactive()) {
    cat(paste0(..., collapse = ""))
    return(utils::menu(c(yes, no)) == 2)
  }
  FALSE
}

## returns TRUE if user says "yes"
##         FALSE otherwise
yep <- function(..., yes = "yes", no = "no") {
  if (is_interactive()) {
    cat(paste0(..., collapse = ""))
    return(utils::menu(c(yes, no)) == 1)
  }
  FALSE
}
