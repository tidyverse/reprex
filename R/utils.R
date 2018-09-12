is_toggle <- function(x) {
  length(x) == 1 && is.logical(x) && !is.na(x)
}

is_path <- function(x) {
  length(x) == 1 && is.character(x) && !grepl("\n$", x)
}

locate_input <- function(input) {
  if (is.null(input)) return("clipboard")
  if (is_path(input)) {
    "path"
  } else {
    "input"
  }
}

read_lines <- function(path) {
  if (is.null(path)) return(NULL)
  readLines(path)
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
    return(suppressWarnings(clipr::read_clip()))
  }
  message("No input provided and clipboard is not available.")
  character()
}

escape_regex <- function(x) {
  chars <- c("*", ".", "?", "^", "+", "$", "|", "(", ")", "[", "]", "{", "}", "\\")
  gsub(paste0("([\\", paste0(collapse = "\\", chars), "])"), "\\\\\\1", x, perl = TRUE)
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

pandoc2.0 <- function() rmarkdown::pandoc_available("2.0")

enfence <- function(lines,
                    tag = NULL,
                    fallback = "-- nothing to show --") {
  if (length(lines) == 0) {
    lines <- fallback
  }
  paste0(c(tag, "``` sh", lines, "```"), collapse = "\n")
}


inject_file <- function(path, inject_path, pre_process = enfence, ...) {
  lines <- readLines(path, encoding = "UTF-8")
  inject_lines <- readLines(inject_path, encoding = "UTF-8")
  inject_lines <- pre_process(inject_lines, ...)

  inject_locus <- grep(paste0("`", inject_path, "`"), lines, fixed = TRUE)
  lines <- c(
    lines[seq_len(inject_locus - 1)],
    inject_lines,
    lines[-seq_len(inject_locus)]
  )
  writeLines(lines, path)
  path
}

prose <- function(x) {
  paste0("#' ", x)
}
