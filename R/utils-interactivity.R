## wrap clipr::clipr_available() so I can mock it
clipboard_available <- function() {
  if (Sys.getenv("CLIPBOARD_AVAILABLE", unset = TRUE)) {
    return(clipr::clipr_available())
  }
  FALSE
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

user_available <- function() {
  interactive() && !is_testing()
}

## returns TRUE if user says "no"
##         FALSE otherwise
nope <- function(..., yes = "yes", no = "no") {
  if (user_available()) {
    cat(paste0(..., collapse = ""))
    return(utils::menu(c(yes, no)) == 2)
  }
  FALSE
}

## returns TRUE if user says "yes"
##         FALSE otherwise
yep <- function(..., yes = "yes", no = "no") {
  if (user_available()) {
    cat(paste0(..., collapse = ""))
    return(utils::menu(c(yes, no)) == 1)
  }
  FALSE
}
