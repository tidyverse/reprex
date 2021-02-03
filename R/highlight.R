reprex_highlight <- function(rout_file, reprex_file, arg_string = NULL) {
  arg_string <- arg_string %||% highlight_args()
  cmd <- paste0(
    "highlight ",
    " -i ", rout_file,
    " --out-format=rtf --no-trailing-nl --encoding=UTF-8",
    arg_string,
    " -o ", reprex_file
  )
  if (is_windows()) {
    res <- shell(cmd)
  } else {
    res <- system(cmd)
  }
  if (res > 0) {
    abort("`highlight` call unsuccessful.")
  }
  res
}

rtf_requires_highlight <- function(venue) {
  if (venue == "rtf" && !highlight_found()) {
    abort(glue::glue('
      `highlight` command line tool doesn\'t appear to be installed
      Therefore, `venue = "rtf"` is not supported'))
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
