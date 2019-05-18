#' Render a reprex
#'
#' @description
#' Run a bit of R code using [rmarkdown::render()] and write the rendered result
#' to user's clipboard. The goal is to make it easy to share a small
#' reproducible example ("reprex"), e.g., in a GitHub issue. Reprex source can
#' be
#'
#' * read from clipboard
#' * read from current selection or active document in RStudio
#'   (with [reprex_addin()])
#' * provided directly as expression, character vector, or string
#' * read from file
#'
#' reprex can also be used for syntax highlighting (with or without rendering);
#' see below for more.
#'
#' @section Details:
#' The usual "code + commented output" is returned invisibly, put on the
#' clipboard, and written to file. An HTML preview displays in RStudio's Viewer
#' pane, if available, or in the default browser, otherwise. Leading `"> "`
#' prompts, are stripped from the input code. Read more at
#' <https://reprex.tidyverse.org/>.
#'
#' reprex sets specific [knitr options](http://yihui.name/knitr/options/):
#' * Chunk options default to `collapse = TRUE`, `comment = "#>"`,
#'   `error = TRUE`. Note that `error = TRUE`, because a common use case is bug
#'   reporting.
#' * reprex also sets knitr's `upload.fun`. It defaults to
#'   [knitr::imgur_upload()] so figures produced by the reprex appear properly
#'   on GitHub, Stack Overflow, or Discourse. Note that this function requires
#'   the packages httr & xml2 or RCurl & XML, depending on your knitr version.
#'   When `venue = "r"`, `upload.fun` is set to `identity`, so that figures
#'   remain local. In that case, you may also want to set `outfile`.
#' You can supplement or override these options with special comments in your
#' code (see examples).
#'
#' @section Syntax highlighting:
#' A secondary use case for reprex is to produce syntax highlighted code
#' snippets, with or without rendering, to paste into presentation software,
#' such as Keynote or PowerPoint. Use `venue = "rtf"`.
#'
#' This feature is experimental and currently rather limited. It probably only
#' works on macOS and requires the installation of the
#' [highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php)
#' command line tool, which can be installed via
#' [homebrew](https://formulae.brew.sh/formula/highlight). This venue is
#' discussed in [an
#' article](https://reprex.tidyverse.org/articles/articles/rtf.html)
#'
#' @param x An expression. If not given, `reprex()` looks for code in
#'   `input` or on the clipboard, in that order.
#' @param input Character. If has length one and lacks a terminating newline,
#'   interpreted as the path to a file containing reprex code. Otherwise,
#'   assumed to hold reprex code as character vector.
#' @param outfile Optional basename for output files. When `NULL`
#'   (default), reprex writes to temp files below the session temp directory. If
#'   `outfile = "foo"`, expect output files in current working directory,
#'   like `foo_reprex.R`, `foo_reprex.md`, and, if `venue = "r"`,
#'   `foo_rendered.R`. If `outfile = NA`, expect output files in
#'   a location and with basename derived from `input`, if sensible, or in
#'   current working directory with basename derived from [tempfile()]
#'   otherwise.
#' @param venue Character. Must be one of the following (case insensitive):
#' * "gh" for [GitHub-Flavored Markdown](https://github.github.com/gfm/), the
#'   default
#' * "r" for a runnable R script, with commented output interleaved
#' * "rtf" for
#'   [Rich Text Format](https://en.wikipedia.org/wiki/Rich_Text_Format)
#'   (not supported for un-reprexing)
#' * "html" for an HTML fragment suitable for inclusion in a larger HTML
#'   document (not supported for un-reprexing)
#' * "so" for
#'   [Stack Overflow Markdown](https://stackoverflow.com/editing-help#syntax-highlighting).
#'   Note: this is just an alias for "gh", since Stack Overflow started to
#'   support CommonMark-style fenced code blocks in January 2019.
#' * "ds" for Discourse, e.g.,
#'   [community.rstudio.com](https://community.rstudio.com). Note: this is
#'   currently just an alias for "gh".
#' @param advertise Logical. Whether to include a footer that describes when and
#'   how the reprex was created. If unspecified, the option `reprex.advertise`
#'   is consulted and, if that is not defined, default is `TRUE` for venues
#'   `"gh"`, `"html"`, `"so"`, `"ds"` and `FALSE` for `"r"` and `"rtf"`.
#' @param si Logical. Whether to include [sessioninfo::session_info()], if
#'   available, or [sessionInfo()] at the end of the reprex. When `venue` is
#'   "gh", the session info is wrapped in a collapsible details tag. Read more
#'   about [opt()].
#' @param style Logical. Whether to style code with [styler::style_text()].
#'   Read more about [opt()].
#' @param show Logical. Whether to show rendered output in a viewer (RStudio or
#'   browser). Read more about [opt()].
#' @param comment Character. Prefix with which to comment out output, defaults
#'   to `"#>"`. Read more about [opt()].
#' @param render Logical. Whether to call [rmarkdown::render()] on the templated
#'   reprex, i.e. whether to actually run the code. Defaults to `TRUE`. Exists
#'   primarily for the sake of internal testing.
#' @param tidyverse_quiet Logical. Sets the option `tidyverse.quiet`, which
#'   suppresses (`TRUE`, the default) or includes (`FALSE`) the startup message
#'   for the tidyverse package. Read more about [opt()].
#' @param std_out_err Logical. Whether to append a section for output sent to
#'   stdout and stderr by the reprex rendering process. This can be necessary to
#'   reveal output if the reprex spawns child processes or `system()` calls.
#'   Note this cannot be properly interleaved with output from the main R
#'   process, nor is there any guarantee that the lines from standard output and
#'   standard error are in correct chronological order. See [callr::r()] for
#'   more. Read more about [opt()].
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
#' reprex({y <- 1:4; mean(y)}, style = TRUE)
#'
#' # note that you can include newlines in those brackets
#' # in fact, that is often a good idea
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
#' # override a default chunk option
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
#'   #' [reprex](https://github.com/tidyverse/reprex#readme) package!
#'   y <- 1:4
#'   mean(y)
#' }, advertise = FALSE)
#'
#' # read reprex from file
#' tmp <- file.path(tempdir(), "foofy.R")
#' writeLines(c("x <- 1:4", "mean(x)"), tmp)
#' reprex(input = tmp)
#'
#' # read from file and write to similarly-named outfiles
#' reprex(input = tmp, outfile = NA)
#' list.files(dirname(tmp), pattern = "foofy")
#'
#' # clean up
#' file.remove(list.files(dirname(tmp), pattern = "foofy", full.names = TRUE))
#'
#' # write rendered reprex to file
#' tmp <- file.path(tempdir(), "foofy")
#' reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, outfile = tmp)
#' list.files(dirname(tmp), pattern = "foofy")
#'
#' # clean up
#' file.remove(list.files(dirname(tmp), pattern = "foofy", full.names = TRUE))
#'
#' # write reprex to file AND keep figure local too, i.e. don't post to imgur
#' tmp <- file.path(tempdir(), "foofy")
#' reprex({
#'   #+ setup, include = FALSE
#'   knitr::opts_knit$set(upload.fun = identity)
#'
#'   #+ actual-reprex-code
#'   #' Some prose
#'   ## regular comment
#'   (x <- 1:4)
#'   median(x)
#'   plot(x)
#'   }, outfile = tmp)
#' list.files(dirname(tmp), pattern = "foofy")
#'
#' # clean up
#' unlink(
#'   list.files(dirname(tmp), pattern = "foofy", full.names = TRUE),
#'   recursive = TRUE
#' )
#'
#' ## target venue = R, also good for email or Slack snippets
#' ret <- reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, venue = "R")
#' ret
#'
#' ## target venue = html
#' ret <- reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' }, venue = "html")
#' ret
#'
#' ## include prompt and don't comment the output
#' ## use this when you want to make your code hard to execute :)
#' reprex({
#'   #+ setup, include = FALSE
#'   knitr::opts_chunk$set(comment = NA, prompt = TRUE)
#'
#'   #+ actual-reprex-code
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' })
#'
#' ## leading prompts are stripped from source
#' reprex(input = c("> x <- 1:3", "> median(x)"))
#' }
#'
#' @import rlang
#' @import fs
#' @export
reprex <- function(x = NULL,
                   input = NULL, outfile = NULL,
                   venue = c("gh", "r", "rtf", "html", "so", "ds"),

                   render = TRUE,

                   advertise       = NULL,
                   si              = opt(FALSE),
                   style           = opt(FALSE),
                   show            = opt(TRUE),
                   comment         = opt("#>"),
                   tidyverse_quiet = opt(TRUE),
                   std_out_err     = opt(FALSE)) {

  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- ds_is_gh(venue)
  venue <- so_is_gh(venue)
  venue <- rtf_requires_highlight(venue)

  advertise       <- advertise %||%
    getOption("reprex.advertise") %||% (venue %in% c("gh", "html"))
  si              <- arg_option(si)
  style           <- arg_option(style)
  show            <- arg_option(show)
  comment         <- arg_option(comment)
  tidyverse_quiet <- arg_option(tidyverse_quiet)
  std_out_err     <- arg_option(std_out_err)

  if (!is.null(input)) stopifnot(is.character(input))
  if (!is.null(outfile)) stopifnot(is.character(outfile) || is.na(outfile))
  stopifnot(is_toggle(advertise), is_toggle(si), is_toggle(style))
  stopifnot(is_toggle(show), is_toggle(render))
  stopifnot(is.character(comment))
  stopifnot(is_toggle(tidyverse_quiet), is_toggle(std_out_err))

  x_expr <- substitute(x)
  where <- if (is.null(x_expr)) locate_input(input) else "expr"
  src <- switch(
    where,
    expr      = stringify_expression(x_expr),
    clipboard = ingest_clipboard(),
    path      = read_lines(input),
    input     = escape_newlines(sub("\n$", "", input)),
    NULL
  )
  src <- ensure_not_empty(src)
  src <- ensure_not_dogfood(src)
  src <- ensure_no_prompts(src)
  if (style) {
    src <- ensure_stylish(src)
  }

  outfile_given <- !is.null(outfile)
  infile <- if (where == "path") input else NULL
  files <- make_filenames(make_filebase(outfile, infile))

  r_file <- files[["r_file"]]
  if (would_clobber(r_file)) { return(invisible()) }
  std_file <- if (std_out_err) files[["std_file"]] else NULL

  data <- list(
    venue = venue, advertise = advertise, si = si,
    comment = comment, tidyverse_quiet = tidyverse_quiet, std_file = std_file
  )
  src <- apply_template(src, data)
  xfun::write_utf8(src, r_file)
  if (outfile_given) {
    message("Preparing reprex as .R file:\n  * ", r_file)
  }

  if (!render) {
    return(invisible(xfun::read_utf8(r_file, error = FALSE)))
  }

  message("Rendering reprex...")
  reprex_render(r_file, std_file)
  ## 1. when venue = "r" or "rtf", the reprex_file != md_file, so we need both
  ## 2. use our own "md_file" instead of the normalized, absolutized path
  ##    returned by rmarkdown::render() and, therefore, reprex_()
  reprex_file <- md_file <- files[["md_file"]]

  if (std_out_err) {
    ## replace "std_file" placeholder with its contents
    inject_file(md_file, std_file, tag = "standard output and standard error")
  }

  if (outfile_given) {
    message("Writing reprex markdown:\n  * ", md_file)
  }

  if (venue %in% c("r", "rtf")) {
    rout_file <- files[["rout_file"]]
    output_lines <- xfun::read_utf8(md_file)
    output_lines <- convert_md_to_r(output_lines, comment = comment)
    writeLines(output_lines, rout_file)
    if (outfile_given) {
      message("Writing reprex as commented R script:\n  * ", rout_file)
    }
    reprex_file <- rout_file
  }

  if (venue == "rtf") {
    rtf_file <- files[["rtf_file"]]
    reprex_highlight(reprex_file, rtf_file)
    if (outfile_given) {
      message("Writing reprex as highlighted RTF:\n  * ", reprex_file)
    }
    reprex_file <- rtf_file
  }

  if (venue == "html") {
    html_fragment_file <- files[["html_fragment_file"]]
    rmarkdown::render(
      md_file,
      output_format = rmarkdown::html_fragment(self_contained = FALSE),
      output_file = html_fragment_file,
      clean = FALSE,
      quiet = TRUE,
      encoding = "UTF-8",
      output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
    )
    reprex_file <- html_fragment_file
  }

  if (show) {
    html_file <- files[["html_file"]]
    rmarkdown::render(
      md_file,
      output_file = html_file,
      clean = FALSE,
      quiet = TRUE,
      encoding = "UTF-8",
      output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
    )

    ## html must live in session temp dir in order to display within RStudio
    html_file <- force_tempdir(html_file)
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(html_file)
  }

  out_lines <- xfun::read_utf8(reprex_file)

  if (clipboard_available()) {
    clipr::write_clip(out_lines)
    message("Rendered reprex is on the clipboard.")
  } else if (interactive()) {
    clipr::dr_clipr()
    message(
      "Unable to put result on the clipboard. How to get it:\n",
      "  * Capture what `reprex()` returns.\n",
      "  * Consult the output file. Control via `outfile` argument.\n",
      "Path to `outfile`:\n",
      "  * ", reprex_file
    )
    if (yep("Open the output file for manual copy?")) {
      withr::defer(utils::file.edit(reprex_file))
    }
  }

  invisible(out_lines)
}

reprex_render <- function(input, std_out_err = NULL) {
  callr::r_safe(
    function(input) {
      options(
        keep.source = TRUE,
        rlang_trace_top_env = globalenv(),
        crayon.enabled = FALSE
      )
      rmarkdown::render(input, quiet = TRUE, envir = globalenv())
    },
    args = list(input = input),
    spinner = interactive(),
    stdout = std_out_err,
    stderr = std_out_err
  )
}

reprex_highlight <- function(rout_file, reprex_file, arg_string = NULL) {
  arg_string <- arg_string %||% highlight_args()
  cmd <- paste0(
    "highlight ", rout_file,
    " --out-format=rtf --no-trailing-nl --encoding=UTF-8",
    arg_string,
    " > ", reprex_file
  )
  res <- system(cmd)
  if (res > 0) {
    stop("`highlight` call unsuccessful.", call. = FALSE)
  }
  res
}

rtf_requires_highlight <- function(venue) {
  if (venue == "rtf" && !highlight_found()) {
    stop(
      "`highlight` command line tool doesn't appear to be installed.\n",
      "Therefore, `venue = \"rtf\"` is not supported.",
      call. = FALSE
    )
  }
  invisible(venue)
}

highlight_found <- function() Sys.which("highlight") != ""

highlight_args <- function() {
  hl_style  <-         getOption("reprex.highlight.hl_style", "darkbone")
  font      <- shQuote(getOption("reprex.highlight.font", "Courier Regular"))
  font_size <-         getOption("reprex.highlight.font_size", 50)
  other     <-         getOption("reprex.highlight.other", "")

  paste0(
    " --style ",     hl_style,
    " --font ",      font,
    " --font-size ", font_size,
    " ", other
  )
}
