#' reprex output format
#'
#' This is an R Markdown output format designed specifically for making
#' "reprexes", typically created via the [reprex()] function, which ultimately
#' renders the document with [reprex_render()]. It is a heavily modified version
#' of [rmarkdown::md_document()]. The arguments have different spheres of
#' influence:
#'   * `venue` potentially affects input preparation and [reprex_render()].
#'   * Add content to the primary input, prior to rendering:
#'     - `advertise`
#'     - `session_info`
#'     - `std_out_err` (also consulted by [reprex_render()])
#'   * Influence knitr package or chunk options:
#'     - `style`
#'     - `comment`
#'     - `tidyverse_quiet`
#'   * `html_preview` is only consulted by [reprex_render()], but it is a formal
#'     argument of `reprex_document()` so that it can be included in the YAML
#'     frontmatter.
#'
#' @inheritParams reprex
#' @inheritParams rmarkdown::md_document
#' @return An R Markdown output format to pass to [rmarkdown::render()].
#' @export
#' @examples
#' reprex_document()
reprex_document <- function(venue = c("gh", "r", "rtf", "html", "so", "ds"),

                            advertise       = NULL,
                            session_info    = opt(FALSE),
                            style           = opt(FALSE),
                            comment         = opt("#>"),
                            tidyverse_quiet = opt(TRUE),
                            std_out_err     = opt(FALSE),
                            pandoc_args = NULL,
                            # must exist, so that it is tolerated in the YAML
                            html_preview) {
  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- normalize_venue(venue)

  advertise       <- set_advertise(advertise, venue)
  session_info    <- arg_option(session_info)
  style           <- arg_option(style)
  style           <- style_requires_styler(style)
  # html_preview is actually an input for for reprex_render()
  comment         <- arg_option(comment)
  tidyverse_quiet <- arg_option(tidyverse_quiet)
  std_out_err     <- arg_option(std_out_err)

  stopifnot(is_toggle(advertise), is_toggle(session_info), is_toggle(style))
  stopifnot(is.character(comment))
  stopifnot(is_toggle(tidyverse_quiet), is_toggle(std_out_err))

  opts_chunk <- list(
    # fixed defaults
    collapse = TRUE, error = TRUE,
    # explicitly exposed for user configuration
    comment = comment,
    R.options = list(tidyverse.quiet = tidyverse_quiet)
  )
  if (isTRUE(style)) {
    opts_chunk[["tidy"]] <- "styler"
  }
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
      # instead of the to-be-knitted (post-spinning) input, but I need to
      # operate on the latter. So I brute force the correct path.
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
        input_lines <- c(input_lines, "", si(details = venue %in% c("gh", "html")))
      }

      write_lines(input_lines, knit_input)
    }
  }

  # output_format$post-processor ----
  # The post_processor is run after processing with Pandoc.
  # It is the last substantial operation before `render()` returns.
  #
  # Important points about a valid post_processor:
  # * The signature is non-negotiable.
  # * `input_file` is the primary input to ?pandoc conversion? (gosh, it's hard
  #   to tell) and I believe it's not relevant to us.
  # * MUST return a file path that is, morally, the (new) `output_file`.
  # * `output_file` is the output of ?pandoc conversion? (see above re: how it
  #   is hard to tell) and all previously run post_processors. I think it is the
  #   true input of a post_processor.

  # used only for debugging / devel purposes
  pp_save_pp_args <- function(metadata,
                              input_file, output_file,
                              clean, verbose) {
    save(
      metadata, input_file, output_file, clean, verbose,
      file = tempfile(),
      #file = "~/rrr/reprex/post_processor_args.RData",
      version = 2
    )
    output_file
  }

  # used when venue is "r" or "rtf"
  pp_md_to_r <- function(metadata,
                         input_file, output_file,
                         clean, verbose) {
    rout_file <- r_file_rendered(output_file)
    output_lines <- read_lines(output_file)
    output_lines <- convert_md_to_r(output_lines, comment = comment)
    write_lines(output_lines, rout_file)
    output_file
  }

  # used when venue is "rtf"
  pp_highlight <- function(metadata,
                           input_file, output_file,
                           clean, verbose) {
    browser()
    rout_file <- r_file_rendered(output_file)
    rtf_file <- rtf_file(output_file)
    reprex_highlight(rout_file, rtf_file)
    output_file
  }

  # used when venue is "html"
  pp_html_render <- function(metadata,
                             input_file, output_file,
                             clean, verbose) {
    # I bet this is fragile, if input is 'foo/foo' for same reason as with
    # main render call in reprex_render()
    # where I decided to use let render() determine output and I take it
    # from the return value
    # I might have to accomplish the path I want by copying the input (the md)
    # to something with "fragment" in it, then let the html file name be
    # auto-generated
    html_file <- html_file(output_file)
    rmarkdown::render(
      output_file,
      output_format = rmarkdown::html_fragment(self_contained = FALSE),
      output_file = html_file,
      clean = FALSE,
      quiet = TRUE,
      encoding = "UTF-8",
      output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
    )
    output_file
  }

  # rmarkdown::merge_post_processors() is First In Last Run
  pp_push <- get("merge_post_processors", asNamespace("rmarkdown"))
  # Therefore we start with a dummy post_processor.
  post_processor <- function(metadata,
                             input_file, output_file,
                             clean, verbose) { output_file }
  if (venue == "html") {
    post_processor <- pp_push(post_processor, pp_html_render)
  }
  if (venue == "rtf") {
    post_processor <- pp_push(post_processor, pp_highlight)
  }
  if (venue %in% c("r", "rtf")) {
    post_processor <- pp_push(post_processor, pp_md_to_r)
  }
  #post_processor <- pp_push(post_processor, pp_save_pp_args)

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
    post_processor = post_processor,
    base_format = rmarkdown::md_document()
  )
  format
}

std_out_err_stub <- function(input) {
  backtick(std_file(input))
}

ad <- function(venue) {
  txt <- paste0(
    "Created on `r Sys.Date()` by the ",
    "[reprex package](https://reprex.tidyverse.org) ",
    "(v`r utils::packageVersion(\"reprex\")`)"
  )
  if (venue %in% c("gh", "so", "html")) {
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
  txt
}

session_info_string <- function() {
  if (rlang::is_installed("sessioninfo")) {
    "sessioninfo::session_info()"
  } else {
    "sessionInfo()"
  }
}
