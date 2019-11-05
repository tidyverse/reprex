#' reprex document format
#'
#' @inheritParams reprex
#' @inheritParams rmarkdown::md_document
#' @return something
#' @export
reprex_document <- function(venue = c("gh", "r", "rtf", "html", "so", "ds"),
                            session_info = FALSE,
                            comment = "#>",
                            tidyverse_quiet = TRUE,
                            pandoc_args = NULL) {
  #html_preview = FALSE,
  #keep_html = FALSE

  venue <- tolower(venue)
  venue <- match.arg(venue)

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

  pandoc_args <- c(
    pandoc_args,
    if (rmarkdown::pandoc_available()) {
      if (rmarkdown::pandoc_version() < "1.16") "--no-wrap" else "--wrap=preserve"
    }
  )

  pre_knit <- function(input, ...) {
    if (!isTRUE(session_info)) { return() }
    # I don't know why the pre_knit hook operates on the **original** input
    # instead of the to-be-knitted input, but I need to operate on the latter.
    # So I brute force the correct path.
    knit_input <- sub(".R$", ".spin.Rmd", input)
    knit_input_lines <- read_lines(knit_input)
    # TO RECONSIDER: once I am convinced that so == gh, I can eliminate the
    # `details` argument of `si()`. Empirically, there seems to be no downside
    # on SO when we embed session info in the html tags that are favorable for
    # GitHub. They apparently are ignored.
    knit_input_lines <- c(knit_input_lines, "", si(details = venue == "gh"))
    write_lines(knit_input_lines, knit_input)
  }

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
    pre_knit = pre_knit,
    base_format = rmarkdown::md_document()
  )
  format
}
