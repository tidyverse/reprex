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
    #abort("Failed to put RTF on the Windows clipboard")
    reprex_danger("Failed to put RTF on the Windows clipboard :(")
    invisible(FALSE)
  } else {
    invisible(TRUE)
  }
}

# this function basically returns the option, but with a hard NO if we detect
# we're on RStudio server
#
# meant to reflect structural (lack of) clipboard availability, which is
# not exactly same as clipr::clipr_available()'s empirical check of "try it
# and see if it works"
reprex_clipboard <- function() {
  x <- getOption("reprex.clipboard", NA)
  if (length(x) != 1 || !is.logical(x)) {
    abort(glue::glue("
      The `reprex.clipboard` option must be TRUE, FALSE, or (logical) NA"))
  }
  if (is_rstudio_server()) {
    options("reprex.clipboard" = FALSE)
  }
  getOption("reprex.clipboard", NA)
}

clipboard_available <- function() {
  if (isFALSE(reprex_clipboard())) {
    FALSE
  } else {
    clipr::clipr_available()
  }
}
