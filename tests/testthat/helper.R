## used to make clipboard unavailable locally
#Sys.setenv("CLIPBOARD_AVAILABLE" = TRUE)
#Sys.setenv("CLIPBOARD_AVAILABLE" = FALSE)

skip_if_no_clipboard <- function() {
  if (!clipboard_available()) {
    skip("System clipboard is not available - skipping test.")
  }
  return(invisible(TRUE))
}
