#' reprex document format
#'
#' @inheritParams reprex
#' @inheritParams rmarkdown::md_document
#' @return something
#' @export
reprex_document <- function(venue = c("gh", "r", "rtf", "html", "so", "ds"),
                            pandoc_args = NULL,
                            comment = "#>",
                            tidyverse_quiet = TRUE) {
  #html_preview = FALSE,
  #keep_html = FALSE

  venue <- tolower(venue)
  venue <- match.arg(venue)

  pandoc_args <- c(
    pandoc_args,
    if (rmarkdown::pandoc_available()) {
      if (rmarkdown::pandoc_version() < "1.16") "--no-wrap" else "--wrap=preserve"
    }
  )

  opts_chunk <- list(
    # fixed defaults
    collapse = TRUE, error = TRUE,
    # explicitly exposed for user configuration
    comment = comment,
    R.options = list(tidyverse.quiet = tidyverse_quiet)
  )
  opts_knit <- list(
    upload.fun = switch(
      venue,
      r = identity,
      knitr::imgur_upload
    )
  )

  format <- rmarkdown::output_format(
    knitr = rmarkdown::knitr_options(
      opts_knit = opts_knit,
      opts_chunk = opts_chunk
    ),
    pandoc = rmarkdown::pandoc_options(
      to = "commonmark",
      from = rmarkdown::from_rmarkdown(implicit_figures = FALSE),
      ext = ".md",
      args = pandoc_args
    ),
    clean_supporting = FALSE,
    base_format = rmarkdown::md_document()
  )
  format
}
