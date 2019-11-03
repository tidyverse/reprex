#' reprex document format
#'
#' @return something
#' @export
reprex_document <- function(pandoc_args = NULL) {
  #html_preview = FALSE,
  #keep_html = FALSE

  format <- rmarkdown::md_document(
    pandoc_args = pandoc_args
  )

  format
}
