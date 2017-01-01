#' Render a reprex
#'
#' Run a bit of R code using \code{\link[rmarkdown]{render}()}. The goal is to
#' make it easy to share a small reproducible example ("reprex"), e.g., in a
#' GitHub issue. Reprex source can be
#' \itemize{
#' \item read from clipboard
#' \item read from current selection or active document
#' (\link[=reprex_addin]{"Render reprex" RStudio addin})
#' \item provided directly as expression, character vector, or string
#' \item read from file
#' }
#' The usual "code + commented output" is returned invisibly, put on the
#' clipboard, and written to file. An HTML preview displays in RStudio's Viewer
#' pane, if available, or in the default browser, otherwise.
#'
#' reprex sets specific \href{http://yihui.name/knitr/options/}{knitr options},
#' which you can supplement or override via the \code{opts_chunk} and
#' \code{opts_knit} arguments or via explicit calls to knitr in your reprex code
#' (see examples). If all you want to override is the \code{comment} option, use
#' the dedicated argument, e.g.\code{commment = "#;-)"}.
#'
#' \itemize{
#' \item Chunk options default to \code{collapse = TRUE}, \code{comment = "#>"},
#' \code{error = TRUE}. These are options you normally set via
#' \code{knitr::opts_chunk$set()}. Note that \code{error = TRUE}, because a
#' common use case is bug reporting.
#' \item Package options default to \code{upload.fun = knitr::imgur_upload}.
#' These are options you normally set via \code{knitr::opts_knit$set()}. The
#' \code{upload.fun} defaults to \code{\link[knitr]{imgur_upload}} so figures
#' produced by the reprex appear properly on GitHub.
#' }
#'
#' @param x An expression. If not given, \code{reprex()} looks for code in
#'   \code{input} or on the clipboard, in that order.
#' @template venue
#' @param si Whether to include the results of
#'   \code{\link[devtools]{session_info}()}, if available, or
#'   \code{\link{sessionInfo}()} at the end of the reprex. When \code{venue =
#'   "gh"} (the default), session info is wrapped in a collapsible details tag.
#' @param show Whether to show rendered output in a viewer (RStudio or browser).
#'   Defaults to \code{TRUE}.
#' @param input Character. If has length one and lacks a terminating newline,
#'   interpreted as the path to a file containing reprex code. Otherwise,
#'   assumed to hold reprex code as character vector (length greater than one)
#'   or string (with embedded newlines).
#' @param outfile Optional basename for output files. When \code{NULL}
#'   (default), reprex writes to temp files below the session temp directory. If
#'   \code{outfile = "foo"}, expect output files in current working directory,
#'   like \code{foo_reprex.R}, \code{foo_reprex.md}, \code{foo_reprex.html},
#'   and, if \code{venue = "R"}, \code{foo_rendered.R}.
#' @param opts_chunk,opts_knit Named list. Optional
#'   \href{http://yihui.name/knitr/options/}{knitr chunk and package options},
#'   respectively, to supplement or override reprex defaults. See Details.
#'
#' @return Character vector of rendered reprex, invisibly.
#' @examples
#' \dontrun{
#' # put some code like this on the clipboard
#' # (y <- 1:4)
#' # mean(y)
#' reprex()
#'
#' # provide code as an expression
#' reprex(rbinom(3, size = 10, prob = 0.5))
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
#' ## customize the output comment prefix
#' reprex(rbinom(3, size = 10, prob = 0.5), comment = "#;-)")
#'
#' # override a default chunk option, in general
#' reprex({(y <- 1:4); median(y)}, opts_chunk = list(collapse = FALSE))
#' # the above is simply shorthand for this and produces same result
#' reprex({
#'   #+ setup, include = FALSE
#'   knitr::opts_chunk$set(collapse = FALSE)
#'
#'   #+ actual-reprex-code
#'   (y <- 1:4)
#'   median(y)
#' })
#'
#' # add prose, use general markdown formatting
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
#'
#' ## target venue = StackOverflow
#' ## http://stackoverflow.com/editing-help
#' ret <- reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, venue = "so")
#' ret
#'
#' ## target venue = R, also good for email or Slack snippets
#' ret <- reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, venue = "R")
#' ret
#' }
#'
#' @importFrom knitr opts_chunk
#' @export
reprex <- function(
  x = NULL, venue = c("gh", "so", "r", "R"), si = FALSE, show = TRUE,
  input = NULL, outfile = NULL,
  comment = "#>", opts_chunk = NULL, opts_knit = NULL) {

  venue <- tolower(match.arg(venue))
  the_source <- NULL

  ## capture source in character vector
  ##
  ## Do not rearrange this block lightly. If x is expression, take care to not
  ## evaluate in this frame.
  x_captured <- substitute(x)
  expr_input <- !is.null(x_captured) ## signals code may need re-formatting
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

  r_file <- strip_ext(outfile) %||% tempfile() ## foo or foo.md --> foo
  r_file <- add_suffix(r_file, "reprex")       ## foo --> foo_reprex
  r_file <- add_ext(r_file)                    ## foo_reprex.R

  if (file.exists(r_file)) {
    stop("`", r_file, "` already exists.", call. = FALSE)
  }

  the_source <- ensure_not_empty(the_source)
  the_source <- ensure_not_dogfood(the_source)
  opts_chunk <- prep_opts(substitute(opts_chunk), which = "chunk")
  opts_knit <- prep_opts(substitute(opts_knit), which = "knit")
  the_source <-
    apply_template(list(
      so = identical(venue, "so"),
      gh = venue %in% c("gh", "r"),
      si = isTRUE(si),
      devtools = requireNamespace("devtools", quietly = TRUE),
      comment = comment,
      user_opts_chunk = opts_chunk,
      user_opts_knit = opts_knit,
      chunk_tidy = prep_tidy(expr_input),
      body = paste(the_source, collapse = "\n")
    ))

  writeLines(the_source, r_file)
  r_file <- normalizePath(r_file)

  output_file <- md_file <- reprex_(r_file)

  output_lines <- readLines(md_file)
  if (identical(venue, "r")) {
    lns <- output_lines
    line_info <- classify_lines_bt(lns, comment = comment)
    lns <- ifelse(line_info == "prose" & nzchar(lns), paste("#'", lns), lns)
    lns <- lns[line_info != "bt" & nzchar(lns)]
    output_lines <- lns
    output_file <- gsub("_reprex", "_rendered", r_file)
    writeLines(output_lines, output_file)
  }

  if (clipboard_available()) {
    clipr::write_clip(output_lines)
  } else {
    message("Unable to put result on the clipboard. How to get it:\n",
            "  * Capture what reprex() returns.\n",
            "  * Use `outfile = \"foo\"` to write output to current working directory.\n",
            "  * See the temp file:\n",
            output_file)
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
