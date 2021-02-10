ingest_clipboard <- function() {
  if (reprex_clipboard()) {
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
    #abort("Failed to put RTF on the Windows clipboard")
    reprex_danger("Failed to put RTF on the Windows clipboard :(")
    invisible(FALSE)
  } else {
    invisible(TRUE)
  }
}

# reports clipr::clipr_available(), with some exceptions and niceties
# - if we detect RStudio server, hard FALSE
# - otherwise, if clipr_available() reports FALSE, call dr_clipr() ONCE
# - use an option to persist this finding in current session
reprex_clipboard <- function() {
  x <- getOption("reprex.clipboard", NA)
  if (length(x) != 1 || !is.logical(x)) {
    abort(glue::glue("
      The `reprex.clipboard` option must be TRUE, FALSE, or (logical) NA"))
  }
  if (is_rstudio_server()) {
    x <- FALSE
    options(reprex.clipboard = x)
  }
  if (is.na(x)) {
    y <- clipr::clipr_available()
    if (isFALSE(y)) {
      clipr::dr_clipr()
    }
    options(reprex.clipboard = y)
  }
  getOption("reprex.clipboard")
}
