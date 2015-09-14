read_from_template <- function(SLUG) {
  SLUG_path <-
    system.file("templates", paste0(SLUG, ".R"), package = "reprex")
  readLines(SLUG_path)
}


#' format deparsed code, removing brackets and starts of lines if necessary
#'
#' @param deparsed A character vector from a use of deparse
format_deparsed <- function(deparsed) {
  # if surrounded by brackets, remove them
  if (length(deparsed) > 0 &&
      deparsed[1] == "{" &&
      tail(deparsed, 1) == "}") {
    deparsed <- tail(head(deparsed, -1), -1)
  }

  # if all lines are indented (such as in expression), indent them to same degree
  # (note that we're not trimming *all* starting whitespace)
  indents <- stringr::str_match(deparsed, "^\\s+")[, 1]
  if (!any(is.na(indents))) {
    # all are indented at least a bit
    deparsed <- stringr::str_sub(deparsed,
                                 start = min(stringr::str_length(indents)) + 1)
  }

  deparsed
}

si <- function() {
  if (requireNamespace("devtools", quietly = TRUE)) {
    "devtools::session_info()"
  } else {
    "sessionInfo()"
  }
}

