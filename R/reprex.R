#' Render a reprex
#'
#' Given some R code on the clipboard or in an expression, character vector,
#' string, or file, this function runs it via \code{\link[rmarkdown]{render}()}.
#' The resulting bit of Markdown is the primary output. It is ready and waiting
#' on the clipboard, for pasting into a GitHub issue, for example. Optionally,
#' the R code and Markdown are left behind in files. An HTML preview displays in
#' RStudio's Viewer pane, if available, or in the default browser otherwise.
#'
#' reprex sets specific \href{http://yihui.name/knitr/options/}{knitr options},
#' which you can supplement or override via the \code{opts_chunk} and
#' \code{opts_knit} arguments or via explicit calls to knitr in your reprex
#' code (see examples).
#'
#' \itemize{
#' \item Chunk options: \code{collapse = TRUE}, \code{comment = '#>'},
#' \code{error = TRUE}. These are options you normally set via
#' \code{knitr::opts_chunk$set()}. Note that \code{error = TRUE} because a
#' common use case is bug reporting.
#' \item Package options: \code{upload.fun = knitr::imgur_upload}. These are
#' options you normally set via \code{knitr::opts_knit$set()}. The
#' \code{upload.fun} defaults to \code{\link[knitr]{imgur_upload}} so figures
#' produced by the reprex appear properly on GitHub.
#' }
#'
#' @param x An expression. If not given, \code{reprex()} looks for code in
#'   \code{input} or on the clipboard, in that order.
#' @param venue "gh" for GitHub (default) or "so" for StackOverflow.
#' @param si Whether to include the results of
#'   \code{\link[devtools]{session_info}()}, if available, or
#'   \code{\link{sessionInfo}()} at the end of the reprex. When \code{venue =
#'   "gh"} (the default), session info is wrapped in a collapsible details tag.
#' @param show Whether to show rendered output in a viewer (RStudio or browser).
#' @param input Character. If has length one and lacks a terminating newline,
#'   interpreted as the path to a file containing reprex code. Otherwise assumed
#'   to hold reprex code as character vector (length greater than one) or string
#'   (with embedded newlines).
#' @param outfile Desired basename for output \code{.R}, \code{.md}, and
#'   \code{.html} files for reproducible example, all written to current
#'   working directory. Any existing \code{.md} extension is stripped to get a
#'   file basename. If \code{NULL}, reprex writes to temp files below the
#'   session temp directory.
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
#' ## provide code via character vector
#' reprex(input = c("x <- 1:4", "y <- 2:5", "x + y"))
#'
#' ## if just one line, terminate with '\n'
#' reprex(input = "rnorm(3)\n")
#'
#' # how to override a default chunk option
#' reprex({y <- 1:4; median(y)}, opts_chunk = list(comment = "#;-)"))
#' # the above is simply shorthand for this and produces same result
#' reprex({
#'   #+ setup, include = FALSE
#'   knitr::opts_chunk$set(comment = '#;-)')
#'
#'   #+ actual-reprex-code
#'   y <- 1:4
#'   mean(y)
#' })
#'
#' # how to add some prose and use general markdown formatting
#' reprex({
#'   #' # A Big Heading
#'   #'
#'   #' Look at my cute example. I love the
#'   #' [reprex](https://github.com/jennybc/reprex#readme) package!
#'   y <- 1:4
#'   mean(y)
#' })
#'
#' # read reprex from file
#' writeLines(c("x <- 1:4", "mean(x)"), "foofy.R")
#' reprex(input = "foofy.R")
#' file.remove("foofy.R")
#'
#' # write rendered reprex to file
#' reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, outfile = "foofy")
#' list.files(pattern = "foofy")
#' file.remove(list.files(pattern = "foofy"))
#' }
#'
#' @importFrom knitr opts_chunk
#' @export
reprex <- function(
  x = NULL, venue = c("gh", "so"), si = FALSE, show = TRUE,
  input = NULL, outfile = NULL,
  opts_chunk = NULL, opts_knit = NULL) {

  venue <- match.arg(venue)
  the_source <- NULL

  ## capture source in character vector
  ##
  ## Do not rearrange this block lightly. If x is expression, take care to not
  ## evaluate in this frame.
  x_captured <- substitute(x)
  expr_input <- !is.null(x_captured)
  if (expr_input) {
    if (!is.null(input)) {
      message("`input` ignored in favor of expression input in `x`.")
    }
    the_source <- stringify_expression(x_captured)
  }

  if (is.null(the_source) && is.null(input)) {
    if (clipboard_available()) {
      suppressWarnings(the_source <- clipr::read_clip())
    } else {
      message("No input provided via `x` or `input` and ",
              "clipboard is not available.")
      the_source <- character()
    }
  }

  if (is.null(the_source)) {
    if (length(input) > 1 || grepl("\n$", input)) {
      the_source <- unlist(strsplit(input, "\n"))
    } else {
      the_source <- readLines(input)
    }
  }

  the_source <- ensure_not_empty(the_source)
  the_source <- ensure_not_dogfood(the_source)

  ## decorate and clean up source
  if (isTRUE(si)) {
    the_source <- add_si(the_source, venue = venue)
  }
  opts_chunk <- prep_opts(substitute(opts_chunk), which = "chunk")
  opts_knit <- prep_opts(substitute(opts_knit), which = "knit")
  chunk_tidy <- prep_tidy(expr_input)
  the_source <-
    add_header(the_source,
               data = list(so = identical(venue, "so"),
                           gh = identical(venue, "gh"),
                           user_opts_chunk = opts_chunk,
                           user_opts_knit = opts_knit,
                           chunk_tidy = chunk_tidy))

  ## write source to .R file
  r_file <- strip_ext(outfile) %||% tempfile()
  r_file <- add_ext(r_file)
  if (file.exists(r_file)) {
    message("Writing output files to '",
            paste0(basename(tools::file_path_sans_ext(r_file)), "-reprex.*'"),
            " to protect '", basename(r_file), "'.")
    r_file <- gsub("\\.R$", "-reprex.R", r_file)
  }
  writeLines(the_source, r_file)
  r_file <- normalizePath(r_file)

  ## render to .md file
  md_file <- reprex_(r_file)

  ## put output on clipboard
  output_lines <- readLines(md_file)
  if (clipboard_available()) {
    clipr::write_clip(output_lines)
  } else {
    message("Unable to put result on the clipboard. How to get it:\n",
            "  * Capture what reprex() returns.\n",
            "  * Use `outfile = \"foo\"` to write output to `foo.md` in current working directory.\n",
            "  * See the temp file:\n",
            md_file)
  }

  if (show) {
    ## if md_file is foo.md and there is also a directory foo_files?
    ## it will be deleted right here
    ## if opts_knit = list(upload.fun = identity), this could hold local figs
    ## until this becomes a problem, just allow that to happen
    ## clean = FALSE causes more than I want to be left behind
    ## no easy way to leave foo_files in the post-md state
    html_file <- rmarkdown::render(md_file, quiet = TRUE)
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(html_file)
  }

  invisible(output_lines)
}

##  input: path to .R
## output: path to .md
reprex_ <- function(r_file) {

  suppressMessages(
    rendout <- try(
      callr::r_safe(function(.input) {
        rmarkdown::render(input = .input, quiet = TRUE)
      },
      args = list(.input = r_file)),
      silent = TRUE
    )
  )

  if (inherits(rendout, "try-error")) {
    stop("\nCannot render this code.\n", rendout)
  }
  rendout

}
