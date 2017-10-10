#' Report when and how reprex was made
#'
#' @return String documenting when reprex was rendered and how
#' @export
#'
#' @examples
#' reprex_info()
reprex_info <- function() {
  msg <- paste("Created on", date(), "with the reprex package")
  message(msg)
  invisible(msg)
}
