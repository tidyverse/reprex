.reprex <- new.env(parent = emptyenv())

.onLoad <- function(...) {
  .reprex[["session_info"]] <- if (requireNamespace("devtools", quietly = TRUE)) {
    "devtools::session_info()"
  } else {
    "sessionInfo()"
  }

  invisible()
}
