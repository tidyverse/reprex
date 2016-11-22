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
#' # or provide it as code in brackets, i.e. as an expression:
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
#' # how to override a default chunk option
#' reprex({y <- 1:4; mean(y)}, opts_chunk = list(comment = "#;-)"))
#' # the above is simply shorthand for this and produces same result
#' reprex({
#'   #+ setup, include = FALSE
#'   knitr::opts_chunk$set(comment = '#;-)')
#'
#'   #+ actual-reprex-code
#'   y <- 1:4
#'   mean(y)
#' })
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
  x_captured <- substitute(x)
  if (is.null(x_captured)) {
    expr_input <- FALSE
    if (is.null(infile)) {
      if (clipboard_available()) {
        suppressWarnings(the_source <- clipr::read_clip())
      } else {
        message("No input provided via `x` or `infile` and clipboard is ",
                "not available.")
        the_source <- character()
      }
    } else {
      the_source <- readLines(infile)
    }
  } else {
    expr_input <- TRUE
    if (!is.null(infile)) {
      message("Input file ignored in favor of expression input in `x`.")
    }
    the_source <- stringify_expression(x_captured)
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
               data = list(so_syntax_highlighting = identical(venue, "so"),
                           user_opts_chunk = opts_chunk,
                           user_opts_knit = opts_knit,
                           chunk_tidy = chunk_tidy))

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
      callr::r_safe(function(.input, .output_format) {
        rmarkdown::render(input = .input, output_format = .output_format,
                          quiet = TRUE)
      },
      args = list(.input = r_file,
                  .output_format = switch(
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
  output_lines <- readLines(md_outfile)
  if (clipboard_available()) {
    clipr::write_clip(output_lines)
  } else {
    message("Unable to put result on the clipboard. How to get it:\n",
            "  * Capture what reprex() returns.\n",
            "  * Use `outfile` argument to specify where to store the result.\n",
            "  * See the temp file:\n",
            md_outfile)
  }

  if (show) {
    html_outfile <- gsub("\\.R$", ".html", r_file)
    ## if md_outfile is foo.md and there is also a directory foo_files?
    ## it will be deleted right here
    ## if opts_knit = list(upload.fun = identity), this could hold local figs
    ## until this becomes a problem, just allow that to happen
    ## clean = FALSE causes more than I want to be left behind
    ## no easy way to leave foo_files in the post-md state
    rmarkdown::render(md_outfile, output_file = html_outfile, quiet = TRUE)
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(html_outfile)
  }

  invisible(output_lines)
}
