is_windows <- function() {
  .Platform$OS.type == "windows"
}

is_path <- function(x) {
  length(x) == 1 && is.character(x) && !grepl("\n$", x)
}

isFALSE <- function(x) identical(x, FALSE)

is_rstudio_server <- function() {
  if (rstudioapi::hasFun("versionInfo")) {
    rstudioapi::versionInfo()$mode == "server"
  } else {
    FALSE
  }
}

in_rstudio <- function() {
  .Platform$GUI == "RStudio"
}

trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

trim_common_leading_ws <- function(x) {
  m <- regexpr("^(\\s*)", x)
  n_chars <- nchar(x)
  n_spaces <- attr(m, which = "match.length")
  num <- min(n_spaces[n_chars > 0])
  substring(x, num + 1)
}

escape_regex <- function(x) {
  chars <- c("*", ".", "?", "^", "+", "$", "|", "(", ")", "[", "]", "{", "}", "\\")
  gsub(paste0("([\\", paste(chars, collapse = "\\"), "])"), "\\\\\\1", x, perl = TRUE)
}

escape_newlines <- function(x) {
  gsub("\n", "\\\\n", x, perl = TRUE)
}

roxygen_comment <- function(x) paste0("#' ", x)

r_chunk <- function(code, label = NULL) {
  c(sprintf("```{r %s}", label %||% ""), label, code, "```")
}

details <- function(txt, desc = "Details") {
  c(
    "<details style=\"margin-bottom:10px;\">",
    glue::glue("<summary>{desc}</summary>"),
    txt,
    "</details>"
  )
}

backtick <- function(x) encodeString(x, quote = "`")

newline <- function(x) paste0(x, "\n")

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
