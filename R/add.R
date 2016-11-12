add_header <- function(x) {
  if (grepl("reprex-header", x[1])) {
    return(x)
  }
  HEADER <- read_from_template("HEADER")
  c(HEADER, x)
}

add_si <- function(x, venue = NULL) c(x, si(venue))

si <- function(venue = NULL) {
  if (!requireNamespace("devtools", quietly = TRUE)) {
    return(c("#'", "sessionInfo()"))
  }
  if (!identical(venue, "gh")) {
    return(c("#'", "devtools::session_info()"))
  }
  c(
    "#'<details><summary>`devtools::session_info()`</summary>",
    "devtools::session_info()",
    "#'</details>"
  )
}
