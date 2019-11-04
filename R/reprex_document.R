#' reprex document format
#'
#' @inheritParams rmarkdown::md_document
#' @return something
#' @export
reprex_document <- function(pandoc_args = NULL,
                            comment = "#>") {
  #html_preview = FALSE,
  #keep_html = FALSE

  pandoc_args <- c(
    pandoc_args,
    if (rmarkdown::pandoc_available()) {
      if (rmarkdown::pandoc_version() < "1.16") "--no-wrap" else "--wrap=preserve"
    }
  )

  opts_chunk <- list(
    collapse = TRUE, error = TRUE,
    comment = comment
    #R.options = list(tidyverse.quiet = TRUE)
  )

  format <- rmarkdown::output_format(
    knitr = rmarkdown::knitr_options(opts_chunk = opts_chunk),
    pandoc = rmarkdown::pandoc_options(
      to = "commonmark",
      from = rmarkdown::from_rmarkdown(implicit_figures = FALSE),
      ext = ".md",
      args = pandoc_args
    ),
    base_format = rmarkdown::md_document()
  )
  format
}
