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

## wrap clipr::clipr_available() so I can tweak its behaviour
clipboard_available <- function() {
  if (is_interactive()) {
    clipr::clipr_available()
  } else {
    isTRUE(as.logical(Sys.getenv("CLIPR_ALLOW", FALSE)))
  }
}
