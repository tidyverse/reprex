is_toggle <- function(x) {
  length(x) == 1 && is.logical(x) && !is.na(x)
}

is_path <- function(x) {
  length(x) == 1 && is.character(x) && !grepl("\n$", x)
}

interactive <- function(...) {
  stop("In this house, we use rlang::is_interactive()")
}

locate_input <- function(input) {
  if (is.null(input)) return("clipboard")
  if (is_path(input)) {
    "path"
  } else {
    "input"
  }
}

read_lines <- function(path, error = FALSE) {
  if (is.null(path)) return(NULL)
  xfun::read_utf8(path, error = error)
}

write_lines <- function(text, path) {
  xfun::write_utf8(text, path)
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

ingest_clipboard <- function() {
  if (clipboard_available()) {
    return(suppressWarnings(enc2utf8(clipr::read_clip())))
  }
  message("No input provided and clipboard is not available.")
  character()
}

escape_regex <- function(x) {
  chars <- c("*", ".", "?", "^", "+", "$", "|", "(", ")", "[", "]", "{", "}", "\\")
  gsub(paste0("([\\", paste(chars, collapse = "\\"), "])"), "\\\\\\1", x, perl = TRUE)
}

escape_newlines <- function(x) {
  gsub("\n", "\\\\n", x, perl = TRUE)
}

ds_is_gh <- function(venue) {
  if (venue == "ds") {
    message(
      "FYI, the Discourse venue \"ds\" is currently an alias for the ",
      "default GitHub venue \"gh\".\nYou don't need to specify it."
    )
    venue <- "gh"
  }
  venue
}

so_is_gh <- function(venue) {
  if (venue == "so") {
    message(
      "FYI, the Stack Overflow venue \"so\" is no longer necessary. Due to ",
      "changes at\nStack Overflow, the markdown produced by the default GitHub ",
      "venue \"gh\" works in\nboth places. You don't need to specify it."
    )
    venue <- "gh"
  }
  venue
}

show_requires_interactive <- function(show) {
  if (show && !is_interactive()) {
    message("Non-interactive session, setting `show = FALSE`.")
    show <- FALSE
  }
  invisible(show)
}

pandoc2.0 <- function() rmarkdown::pandoc_available("2.0")

enfence <- function(lines,
                    tag = NULL,
                    fallback = "-- nothing to show --") {
  if (length(lines) == 0) {
    lines <- fallback
  }
  collapse(c(tag, "``` sh", lines, "```"))
}


inject_file <- function(path, inject_path, pre_process = enfence, ...) {
  lines <- read_lines(path)
  inject_lines <- read_lines(inject_path)
  inject_lines <- pre_process(inject_lines, ...)

  inject_locus <- grep(backtick(path_file(inject_path)), lines, fixed = TRUE)
  if (length(inject_locus)) {
    lines <- c(
      lines[seq_len(inject_locus - 1)],
      inject_lines,
      lines[-seq_len(inject_locus)]
    )
    write_lines(lines, path)
  }
  path
}

roxygen_comment <- function(x) paste0("#' ", x)

r_chunk <- function(code, label = NULL) {
  c(sprintf("```{r %s}", label %||% ""), label, code, "```")
}

collapse <- function(x, sep = "\n") {
  stopifnot(is.character(sep), length(sep) == 1)
  paste(x, collapse = sep)
}

backtick <- function(x) encodeString(x, quote = "`")

newline <- function(x) paste0(x, "\n")
