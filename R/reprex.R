#' Render a reprex
#'
#' Given some R code on the clipboard, in an expression, or in a file, this
#' function runs it via \code{\link[rmarkdown]{render}}. The resulting bit of
#' Markdown is the primary output. It will be ready and waiting on the
#' clipboard, for pasting into a GitHub issue or to stackoverflow. Optionally,
#' the R code and Markdown will be left behind in files. An HTML preview will
#' display in RStudio's Viewer pane, if available, or in the default browser
#' otherwise.
#'
#' reprex sets specific \href{http://yihui.name/knitr/options/}{knitr
#' options}, which you can supplement or override via the \code{opts_chunk} and
#' \code{opts_knit} arguments.
#'
#' \itemize{
#' \item Chunk options: \code{collapse = TRUE}, \code{comment = '#>'},
#' \code{error = TRUE}. Chunk options are typically set via
#' \code{knitr::opts_chunk$set()}.
#' \item Package options: \code{upload.fun = knitr::imgur_upload}. Package
#' options are typically set via \code{knitr::opts_knit$set()}. The
#' \code{upload.fun} defaults to \code{\link[knitr]{imgur_upload}} so figures
#' produced by the reprex appear properly on GitHub.
#' }
#'
#' @param x An expression. If not given, \code{reprex} will look for code in
#'   \code{infile}, if provided, or on the clipboard.
#' @param venue "gh" for GitHub (default) or "so" for stackoverflow.
#' @param si Whether to include the results of
#'   \code{\link[devtools]{session_info}}, if available, or
#'   \code{\link{sessionInfo}} at the end of the reprex. When \code{venue =
#'   "gh"} (the default), session info is wrapped in a collapsible details tag.
#' @param show Whether to show rendered output in a viewer (RStudio or browser).
#' @param infile Path to \code{.R} file containing reprex code.
#' @param outfile Desired stub for output \code{.R}, \code{.md}, and
#'   \code{.html} files for reproducible example. If \code{NULL}, keeps them in
#'   temporary files. At this point, outfiles are deposited in current working
#'   directory, but the goal is to consult options for a place to store all
#'   reprexes.
#' @param opts_chunk,opts_knit Named list. Optional
#'   \href{http://yihui.name/knitr/options/}{knitr chunk and package options},
#'   respectively, to supplement or override reprex defaults. See Details.
#'
#' @examples
#' \dontrun{
#' # put some code like this on the clipboard
#' # (y <- 1:4)
#' # mean(y)
#' reprex()
#'
#' # or provide it as code in brackets:
#' reprex({y <- 1:4; mean(y)})
#'
#' # note that you can include newlines in those brackets
#' # in fact, that is probably a good idea
#' reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' })
#'
#' # overriding a default chunk option
#'  reprex({y <- 1:4; mean(y)}, opts_chunk = list(comment = "#;-)"))
#' }
#'
#' @export
reprex <- function(
  x = NULL, venue = c("gh", "so"), si = FALSE, show = TRUE,
  infile = NULL, outfile = NULL,
  opts_chunk = NULL, opts_knit = NULL) {

  venue <- match.arg(venue)

  ## Do not rearrange this block lightly. If x is expression, take care to not
  ## evaluate in this frame.
  expr_input <- FALSE
  x_captured <- substitute(x)
  if (is.null(x_captured)) {
    if (is.null(infile)) {
      suppressWarnings(the_source <- clipr::read_clip())
    } else {
      the_source <- readLines(infile)
    }
  } else {
    if (!is.null(infile)) {
      message("Input file ignored in favor of expression input in `x`.")
    }
    the_source <- stringify_expression(x_captured)
    expr_input <- TRUE
  }
  the_source <- ensure_not_empty(the_source)
  the_source <- ensure_not_dogfood(the_source)
  if (isTRUE(si)) {
    the_source <- add_si(the_source, venue = venue)
  }

  opts_chunk <- prep_opts(substitute(opts_chunk), which = "chunk")
  opts_knit <- prep_opts(substitute(opts_knit), which = "knit")
  chunk_tidy <- prep_tidy(expr_input)
  the_source <-
    add_header(the_source,
               data = list(user_opts_chunk = opts_chunk,
                           user_opts_knit = opts_knit,
                           chunk_tidy = chunk_tidy))

  ## TO DO: come back here once it's clear how outfile will be used
  ## i.e., is it going to be like original slug concept?
  r_file <- outfile %||% tempfile()
  r_file <- add_ext(r_file)

  writeLines(the_source, r_file)

  r_file <- normalizePath(r_file)

  reprex_(r_file, venue, show)
}

reprex_ <- function(r_file, venue = c("gh", "so"), show = TRUE) {

  venue <- match.arg(venue)

  suppressMessages(
    rendout <- try(
      callr::r_safe(function(input, output_format) {
        rmarkdown::render(input = input, output_format = output_format,
                          quiet = TRUE)
      },
      args = list(input = r_file,
                  output_format = switch(
                    venue,
                    gh = rmarkdown::md_document(variant = "markdown_github"),
                    so = rmarkdown::md_document()
                  ))),
      silent = TRUE)
  )

  if (inherits(rendout, "try-error")) {
    stop("\nCannot render this code.\n", rendout)
  }
  md_outfile <- rendout

  if (venue == "so") {
    md_safe <- readLines(md_outfile)
    writeLines(c("<!-- language: lang-r -->\n", md_safe), md_outfile)
  }

  output_lines <- readLines(md_outfile)
  clipr::write_clip(output_lines)

  if (show) {
    html_outfile <- gsub("\\.R", ".html", r_file)
    rmarkdown::render(md_outfile, output_file = html_outfile, quiet = TRUE)
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(html_outfile)
  }

  invisible(output_lines)
}
