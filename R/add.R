add_header <- function(x, data) {
  if (grepl("reprex-header", x[1])) {
    return(x)
  }
  HEADER <- read_from_template("HEADER")
  HEADER <-
    strsplit(whisker::whisker.render(HEADER, data = data), split = "\n")[[1]]
  c(HEADER, x)
}

add_si <- function(x, venue = NULL) c(x, "", si(venue))

si <- function(venue = NULL) {
  ret <- if (requireNamespace("devtools", quietly = TRUE)) {
    "devtools::session_info()"
  } else {
    "sessionInfo()"
  }
  if (identical(venue, "gh")) {
    ret <- c(
      paste0("#'<details><summary>`", ret, "`</summary>"),
      ret,
      "#'</details>"
    )
  }
  ret
}
