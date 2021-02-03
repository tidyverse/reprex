is_windows <- function() {
  .Platform$OS.type == "windows"
}

is_toggle <- function(x) {
  length(x) == 1 && is.logical(x) && !is.na(x)
}

is_path <- function(x) {
  length(x) == 1 && is.character(x) && !grepl("\n$", x)
}

locate_input <- function(input) {
  if (is.null(input)) {
    return("clipboard")
  }
  if (is_path(input)) {
    "path"
  } else {
    "input"
  }
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
    return(suppressWarnings(
      enc2utf8(clipr::read_clip() %||% character())
    ))
  }
  reprex_warning("No input provided and clipboard is not available.")
  character()
}

write_clip_windows_rtf <- function(path) {
  cmd <- glue::glue('
    powershell -Command "\\
    Add-Type -AssemblyName System.Windows.Forms | Out-Null;\\
    [Windows.Forms.Clipboard]::SetText(
    (Get-Content -Raw {path}),\\
    [Windows.Forms.TextDataFormat]::Rtf
    )"')
  res <- system(cmd)
  if (res > 0) {
    #stop("Failed to put RTF on the Windows clipboard", call. = FALSE)
    reprex_danger("Failed to put RTF on the Windows clipboard :(")
    invisible(FALSE)
  } else {
    invisible(TRUE)
  }
}

escape_regex <- function(x) {
  chars <- c("*", ".", "?", "^", "+", "$", "|", "(", ")", "[", "]", "{", "}", "\\")
  gsub(paste0("([\\", paste(chars, collapse = "\\"), "])"), "\\\\\\1", x, perl = TRUE)
}

escape_newlines <- function(x) {
  gsub("\n", "\\\\n", x, perl = TRUE)
}

pandoc2.0 <- function() rmarkdown::pandoc_available("2.0")

roxygen_comment <- function(x) paste0("#' ", x)

r_chunk <- function(code, label = NULL) {
  c(sprintf("```{r %s}", label %||% ""), label, code, "```")
}

backtick <- function(x) encodeString(x, quote = "`")

newline <- function(x) paste0(x, "\n")

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
