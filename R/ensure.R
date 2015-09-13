ensure_not_empty <- function(x)
  if (length(x) < 1) read_from_template("BETTER_THAN_NOTHING") else x

ensure_not_dogfood <- function(x) {
  if(grepl("```", x[[length(x)]])) {
    stop(paste("\nLast line of putative code is:",
               x[1],
               "which is not going to fly.",
               "Are we going in circles?",
               "Did you perhaps just run reprex()?",
               "In that case, the clipboard now holds the *rendered* result.",
               sep = "\n"))
  } else {
    x
  }
}

ensure_header <- function(x) {
  if(!grepl("reprex-header", x[1])) {
    HEADER <- read_from_template("HEADER")
    c(HEADER, x)
  } else {
    x
  }
}

ensure_si <- function(x, session_info = FALSE)
  if (session_info) c(x, si()) else x
