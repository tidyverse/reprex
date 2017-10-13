#' Report when and how reprex was made
#'
#' @return String documenting when reprex was rendered and how
#' @export
#'
#' @examples
#' reprex_info()
reprex_info <- function() {
  message(
    paste0("Created by the reprex package v", utils::packageVersion("reprex"),
          " on ", Sys.Date())
  )
  invisible()
}
