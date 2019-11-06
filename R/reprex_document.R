#' reprex document format
#'
#' @inheritParams reprex
#' @inheritParams rmarkdown::md_document
#' @return something
#' @export
reprex_document <- function(venue = c("gh", "r", "rtf", "html", "so", "ds"),
                            advertise = NULL,
                            session_info = FALSE,
                            comment = "#>",
                            tidyverse_quiet = TRUE,
                            std_out_err = FALSE,
                            pandoc_args = NULL) {
  #html_preview = FALSE,
  #keep_html = FALSE

  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- normalize_venue(venue)

  advertise <- advertise %||%
    getOption("reprex.advertise") %||% (venue %in% c("gh", "html"))

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

  pre_knit <- NULL
  if (isTRUE(std_out_err) || isTRUE(advertise) || isTRUE(session_info)) {
    pre_knit <- function(input, ...) {

      # I don't know why the pre_knit hook operates on the **original** input
      # instead of the to-be-knitted input, but I need to operate on the latter.
      # So I brute force the correct path.
      knit_input <- sub(".R$", ".spin.Rmd", input)
      input_lines <- read_lines(knit_input)

      if (isTRUE(std_out_err)) {
        input_lines <- c(input_lines, "", std_out_err_stub(input))
      }

      if (isTRUE(advertise)) {
        input_lines <- c(input_lines, "", ad(venue))
      }

      if (isTRUE(session_info)) {
        # TO RECONSIDER: once I am convinced that so == gh, I can eliminate the
        # `details` argument of `si()`. Empirically, there seems to be no downside
        # on SO when we embed session info in the html tags that are favorable for
        # GitHub. They apparently are ignored.
        input_lines <- c(input_lines, "", si(details = venue == "gh"))
      }

      write_lines(input_lines, knit_input)
    }
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

std_out_err_stub <- function(input) {
  std_file <- make_filenames(
    make_filebase(outfile = NA, infile = path_file(input)),
    suffix = "")$std_file
  backtick(std_file)
}

ad <- function(venue) {
  txt <- paste0(
    "Created on `r Sys.Date()` by the ",
    "[reprex package](https://reprex.tidyverse.org) ",
    "(v`r utils::packageVersion(\"reprex\")`)"
  )
  if (venue %in% c("gh", "so")) {
    txt <- paste0("<sup>", txt, "</sup>")
  }
  txt
}

si <- function(details = FALSE) {
  txt <- r_chunk(session_info_string())
  if (details) {
    txt <- c(
      "<details><summary>Session info</summary>",
      txt,
      "</details>"
    )
  }
}

session_info_string <- function() {
  if (rlang::is_installed("sessioninfo")) {
    "sessioninfo::session_info()"
  } else {
    "sessionInfo()"
  }
}
