#' Render a reprex
#'
#' Run a bit of R code using
#' \code{\link[rmarkdown:render]{rmarkdown::render}()}. The goal is to make it
#' easy to share a small reproducible example ("reprex"), e.g., in a GitHub
#' issue. Reprex source can be
#' \itemize{
#' \item read from clipboard
#' \item read from current selection or active document
#' (\link[=reprex_addin]{"Render reprex" RStudio addin})
#' \item provided directly as expression, character vector, or string
#' \item read from file
#' }
#' The usual "code + commented output" is returned invisibly, put on the
#' clipboard, and written to file. An HTML preview displays in RStudio's Viewer
#' pane, if available, or in the default browser, otherwise. Leading \code{"> "}
#' prompts, are stripped from the input code.
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
#'   \code{\link[devtools:session_info]{devtools::session_info}()}, if available, or
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
#'   like \code{foo_reprex.R}, \code{foo_reprex.md}, and, if \code{venue = "R"},
#'   \code{foo_rendered.R}. If \code{outfile = NA}, expect output files in
#'   current working directory with basename derived from the path in
#'   \code{input}, if sensible, otherwise from \code{\link{tempfile}()}.
#' @param comment Character. Prefix with which to comment out output, defaults
#'   to \code{"#>"}.
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
#'
#' # read from file and write to similarly-named outfiles
#' reprex(input = "foofy.R", outfile = NA)
#' list.files(pattern = "foofy")
#' file.remove(list.files(pattern = "foofy"))
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
#' # write reprex to file AND keep figure local too, i.e. don't post to imgur
#' reprex({
#'   #' Some prose
#'   ## regular comment
#'   (x <- 1:4)
#'   median(x)
#'   plot(x)
#'   }, outfile = "blarg", opts_knit = list(upload.fun = identity))
#' list.files(pattern = "blarg")
#' unlink(list.files(pattern = "blarg"), recursive = TRUE)
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
#'
#' ## include prompt and don't comment the output
#' ## use this when you want to make your code hard to execute :)
#' reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, opts_chunk = list(comment = NA, prompt = TRUE))
#'
#' ## leading prompts are stripped from source
#' reprex(input = c("> x <- 1:3", "> median(x)"))
#' }
#'
#' @importFrom knitr opts_chunk
#' @export
reprex <- function(
  x = NULL, venue = c("gh", "so", "r", "R"), si = FALSE, show = TRUE,
  input = NULL, outfile = NULL,
  comment = "#>", opts_chunk = NULL, opts_knit = NULL) {

  venue <- tolower(match.arg(venue))
  stopifnot(is.logical(si), is.logical(show), is.character(comment))
  if (!is.null(input)) stopifnot(is.character(input))
  if (!is.null(outfile)) stopifnot(is.character(outfile) || is.na(outfile))

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

  if (is.null(the_source)) {
    the_source <- ingest_input(input)
  }

  outfile_given <- !is.null(outfile)
  if (outfile_given && is.na(outfile)) {
    if (length(input) == 1 && !grepl("\n$", input)) {
      outfile <- basename(input)
    } else {
      outfile <- basename(tempfile())
    }
  }
  r_file <- strip_ext(outfile) %||% tempfile() ## foo or foo.md --> foo
  r_file <- add_suffix(r_file, "reprex")       ## foo --> foo_reprex
  r_file <- add_ext(r_file)                    ## foo_reprex.R

  if (file.exists(r_file) &&
      yesno("Oops, file already exists:\n  * ", r_file, "\n",
            "Delete it and carry on with this reprex?")) {
    cat("Exiting.\n")
    return(invisible())
  }

  the_source <- ensure_not_empty(the_source)
  the_source <- ensure_not_dogfood(the_source)
  the_source <- ensure_no_prompts(the_source)
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
  if (outfile_given) {
    message("Preparing reprex as .R file to render:\n  * ", r_file)
  }

  output_file <- md_file <- reprex_(r_file)
  if (outfile_given) {
    pathstem <- path_stem(r_file, md_file)
    message("Writing reprex markdown:\n  * ", sub(pathstem, "", md_file))
  }
  output_lines <- readLines(md_file)

  if (identical(venue, "r")) {
    lns <- output_lines
    line_info <- classify_lines_bt(lns, comment = comment)
    lns <- ifelse(line_info == "prose" & nzchar(lns), paste("#'", lns), lns)
    lns <- lns[line_info != "bt"]
    output_lines <- lns
    output_file <- gsub("_reprex", "_rendered", r_file)
    writeLines(output_lines, output_file)
    if (outfile_given) {
      message("Writing reprex as commented R script:\n  * ",
              sub(pathstem, "", output_file))
    }
  }

  if (clipboard_available()) {
    clipr::write_clip(output_lines)
    message("Rendered reprex ready on the clipboard.")
  } else {
    message("Unable to put result on the clipboard. How to get it:\n",
            "  * Capture what reprex() returns.\n",
            "  * Use `outfile = \"foo\"` to request output in specific file.\n",
            "  * See the temp file:\n    - ",
            output_file)
  }

  if (show) {
    ## I want the html to live in session temp dir for two reasons:
    ##   * causes display in RStudio Viewer, if available
    ##   * retains foo_reprex_files but not other html-related intermediates
    ## if outfile = NULL, this happens by default; otherwise, must force it
    ## `clean = FALSE` does too much (deletes foo_reprex_files, which might
    ## hold local figs)
    if (is.null(outfile)) {
      html_file <- rmarkdown::render(md_file, quiet = TRUE)
    } else {
      html_file <- strip_ext(basename(md_file))
      html_file <- tempfile(pattern = paste0(html_file, "_"), fileext = ".html")
      html_file <-
        rmarkdown::render(md_file, output_file = html_file, quiet = TRUE)
    }
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
