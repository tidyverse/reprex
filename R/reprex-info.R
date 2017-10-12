#' Report when and how reprex was made
#'
#' @return String documenting when reprex was rendered and how
#' @export
#'
#' @examples
#' reprex_info()
reprex_info <- function(prefix = "#'") {
  paste(prefix, "Created by the reprex package;", Sys.Date())
}
