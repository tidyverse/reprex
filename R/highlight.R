reprex_highlight <- function(rout_file, reprex_file, arg_string = NULL) {
  arg_string <- arg_string %||% highlight_args()
  out <- ifelse(Platform$OS.type == "windows", " -o ", " > ")
  cmd <- paste0(
    "highlight ", rout_file,
    " --out-format=rtf --no-trailing-nl --encoding=UTF-8",
    arg_string,
    out, reprex_file
  )
  res <- system(cmd)
  if (res > 0) {
    stop("`highlight` call unsuccessful.", call. = FALSE)
  }
  res
}

rtf_requires_highlight <- function(venue) {
  if (venue == "rtf" && !highlight_found()) {
    stop(
      "`highlight` command line tool doesn't appear to be installed.\n",
      "Therefore, `venue = \"rtf\"` is not supported.",
      call. = FALSE
    )
  }
  invisible(venue)
}

highlight_found <- function() Sys.which("highlight") != ""

highlight_args <- function() {
  hl_style  <-         getOption("reprex.highlight.hl_style", "darkbone")
  font      <- shQuote(getOption("reprex.highlight.font", "Courier Regular"))
  font_size <-         getOption("reprex.highlight.font_size", 50)
  other     <-         getOption("reprex.highlight.other", "")

  paste0(
    " --style ",     hl_style,
    " --font ",      font,
    " --font-size ", font_size,
    " ", other
  )
}
