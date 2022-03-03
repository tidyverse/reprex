interactive <- function(...) {
  cli::cli_abort("
    Inside {.pkg reprex}, we use {.fun rlang::is_interactive}, \\
    not {.fun interactive}, for mocking reasons.",
    .internal = TRUE
  )
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
