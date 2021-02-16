#' Render a reprex
#'
#' @description
#' Run a bit of R code using [rmarkdown::render()] and write the rendered result
#' to user's clipboard. If the clipboard is unavailable, the file containing
#' the rendered result is opened for manual copy. The goal is to make it easy to
#' share a small reproducible example ("reprex"), e.g., in a GitHub issue.
#' Reprex source can be
#'
#' * read from clipboard
#' * provided directly as expression, character vector, or string
#' * read from file
#' * read from current selection or active document in RStudio
#'
#' reprex can also be used for syntax highlighting (with or without rendering);
#' see below for more.
#'
#' @section Details:
#' The usual "code + commented output" is returned invisibly, written to file,
#' and, whenever possible, put on the clipboard. An HTML preview displays in
#' RStudio's Viewer pane, if available, or in the default browser, otherwise.
#' Leading `"> "` prompts, are stripped from the input code. Read more at
#' <https://reprex.tidyverse.org/>.
#'
#' reprex sets specific [knitr options](https://yihui.org/knitr/options/):
#' * Chunk options default to `collapse = TRUE`, `comment = "#>"`,
#'   `error = TRUE`. Note that `error = TRUE`, because a common use case is bug
#'   reporting.
#' * reprex also sets knitr's `upload.fun`. It defaults to
#'   [knitr::imgur_upload()] so figures produced by the reprex appear properly
#'   on GitHub, Stack Overflow, Discourse, and Slack. Note that `imgur_upload()`
#'   requires the packages httr and xml2. When `venue = "r"`, `upload.fun` is
#'   set to `identity()`, so that figures remain local. In that case, you may
#'   also want to provide a filepath to `input` or set `wd`, to control where
#'   the reprex files are written.
#' You can supplement or override these options with special comments in your
#' code (see examples).
#'
#' @section Syntax highlighting:
#'
#' `r lifecycle::badge("experimental")`
#'
#' A secondary use case for reprex is to produce syntax highlighted code
#' snippets, with or without rendering, to paste into applications like
#' Microsoft Word, PowerPoint, or Keynote. Use `venue = "rtf"` for this.
#'
#' This feature is experimental and requires the installation of the
#' [highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php)
#' command line tool. The `"rtf"` venue is documented in [its own
#' article](https://reprex.tidyverse.org/articles/articles/rtf.html)
#'
#' @param x An expression. If not given, `reprex()` looks for code in
#'   `input`. If `input` is not provided, `reprex()` looks on the clipboard.
#'
#'   When the clipboard is structurally unavailable, e.g., on RStudio Server or
#'   RStudio Cloud, `reprex()` consults the current selection instead of the
#'   clipboard.
#' @param input Character. If has length one and lacks a terminating newline,
#'   interpreted as the path to a file containing reprex code. Otherwise,
#'   assumed to hold reprex code as character vector. When `input` specifies a
#'   filepath, it also determines the reprex working directory and the location
#'   of all resulting files.
#' @param wd An optional filepath that is consulted when `input` is not a
#'   filepath. (By default, all work is done, quietly, in a subdirectory of the
#'   session temp directory.)
#'
#'   The most common use of `wd` is to set `wd = "."`, which means "reprex right
#'   HERE in the current working directory". Do this if you really must
#'   demonstrate something with local files.
#' @param venue Character. Must be one of the following (case insensitive):
#' * "gh" for [GitHub-Flavored Markdown](https://github.github.com/gfm/), the
#'   default
#' * "r" for a runnable R script, with commented output interleaved. Also useful
#'   for [Slack code snippets](https://slack.com/intl/en-ca/slack-tips/share-code-snippets);
#'   select "R" from the "Type" drop-down menu to enjoy nice syntax
#'   highlighting.
#' * "rtf" for
#'   [Rich Text Format](https://en.wikipedia.org/wiki/Rich_Text_Format)
#'   (not supported for un-reprexing)
#' * "html" for an HTML fragment suitable for inclusion in a larger HTML
#'   document (not supported for un-reprexing)
#' * "slack" for pasting into a Slack message. Works best if you opt out of
#'   Slack's WYSIWYG interface and, instead, go to **Preferences > Advanced**
#'   and select "Format messages with markup".
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
#'   `"gh"`, `"html"`, `"so"`, `"ds"` and `FALSE` for `"r"`, `"rtf"`, `"slack"`.
#' @param session_info Logical. Whether to include
#'   [sessioninfo::session_info()], if available, or [sessionInfo()] at the end
#'   of the reprex. When `venue` is "gh", the session info is wrapped in a
#'   collapsible details tag. Read more about [opt()].
#' @param style Logical. Whether to set the knitr chunk option `tidy =
#'   "styler"`, which re-styles code with the [styler
#'   package](https://styler.r-lib.org). Read more about [opt()].
#' @param comment Character. Prefix with which to comment out output, defaults
#'   to `"#>"`. Read more about [opt()].
#' @param render Logical. Whether to call [rmarkdown::render()] on the templated
#'   reprex, i.e. whether to actually run the code. Defaults to `TRUE`. Exists
#'   primarily for the sake of internal testing.
#' @param tidyverse_quiet Logical. Sets the options `tidyverse.quiet` and
#'   `tidymodels.quiet`, which suppress (`TRUE`, the default) or include
#'   (`FALSE`) the startup messages for the tidyverse and tidymodels packages.
#'   Read more about [opt()].
#' @param std_out_err Logical. Whether to append a section for output sent to
#'   stdout and stderr by the reprex rendering process. This can be necessary to
#'   reveal output if the reprex spawns child processes or `system()` calls.
#'   Note this cannot be properly interleaved with output from the main R
#'   process, nor is there any guarantee that the lines from standard output and
#'   standard error are in correct chronological order. See [callr::r()] for
#'   more. Read more about [opt()].
#' @param html_preview Logical. Whether to show rendered output in a viewer
#'   (RStudio or browser). Always `FALSE` in a noninteractive session. Read more
#'   about [opt()].
#' @param outfile `r lifecycle::badge("deprecated")` in favor of `wd` or
#'   providing a filepath to `input`. To reprex in current working directory,
#'   use `wd = "."` now, instead of `outfile = NA`.
#' @param show `r lifecycle::badge("deprecated")` in favor of `html_preview`,
#'   for greater consistency with other R Markdown output formats.
#' @param si  `r lifecycle::badge("deprecated")` in favor of `session_info`.
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
#' # read reprex from file and write resulting files to that location
#' tmp <- file.path(tempdir(), "foofy.R")
#' writeLines(c("x <- 1:4", "mean(x)"), tmp)
#' reprex(input = tmp)
#' list.files(dirname(tmp), pattern = "foofy")
#'
#' # clean up
#' file.remove(list.files(dirname(tmp), pattern = "foofy", full.names = TRUE))
#'
#' # write reprex to file AND keep figure local too, i.e. don't post to imgur
#' tmp <- file.path(tempdir(), "foofy")
#' dir.create(tmp)
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
#'   }, wd = tmp)
#' list.files(dirname(tmp), pattern = "foofy")
#'
#' # clean up
#' unlink(tmp, recursive = TRUE)
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
                   input = NULL, wd = NULL,
                   venue = c("gh", "r", "rtf", "html", "slack", "so", "ds"),

                   render = TRUE,

                   advertise       = NULL,
                   session_info    = opt(FALSE),
                   style           = opt(FALSE),
                   comment         = opt("#>"),
                   tidyverse_quiet = opt(TRUE),
                   std_out_err     = opt(FALSE),
                   html_preview    = opt(TRUE),
                   outfile = "DEPRECATED",
                   show = "DEPRECATED", si = "DEPRECATED") {
  if (!missing(show)) {
    html_preview <- show
    reprex_warning(
      "{.code show} is deprecated, please use {.code html_preview} instead"
    )
  }

  if (!missing(si)) {
    session_info <- si
    # I kind of regret deprecating this, so let's not make a fuss
    # reprex_warning(
    #   "{.code si} is deprecated, please use {.code session_info} instead"
    # )
  }

  reprex_impl(
    x_expr = substitute(x),
    input = input,
    wd = wd,
    venue = venue,

    render = render,
    new_session = TRUE,

    advertise       = advertise,
    session_info    = session_info,
    style           = style,
    html_preview    = html_preview,
    comment         = comment,
    tidyverse_quiet = tidyverse_quiet,
    std_out_err     = std_out_err,

    outfile = outfile
  )
}
