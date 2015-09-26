add_header <- function(x) {
  if(!grepl("reprex-header", x[1])) {
    HEADER <- read_from_template("HEADER")
    c(HEADER, x)
  } else {
    x
  }
}

add_si <- function(x, si = FALSE) if (si) c(x, si()) else x

si <- function() {
  if (requireNamespace("devtools", quietly = TRUE)) {
    "devtools::session_info()"
  } else {
    "sessionInfo()"
  }
}
