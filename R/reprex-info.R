#' Report when and how reprex was made
#'
#' `reprex_info()` returns a string documenting when the reprex was rendered and
#' how. It is included as the first line of reprex source when `advertise =
#' TRUE`.
#'
#' @return Character
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
