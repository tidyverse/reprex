#' Un-render a reprex
#'
#' @description
#' Recover clean, runnable code from a reprex captured in the wild and write it
#' to user's clipboard. The code is also returned invisibly and optionally
#' written to file. Three different functions address various forms of
#' wild-caught reprex.
#'
#' @inheritParams reprex
#' @param input Character. If has length one and lacks a terminating newline,
#'   interpreted as the path to a file containing reprex code. Otherwise,
#'   assumed to hold reprex code as character vector. If not provided, the
#'   clipboard is consulted for input. If the clipboard is unavailable and
#'   we're in RStudio, the current selection is used.
#' @param comment regular expression that matches commented output lines
#' @param prompt character, the prompt at the start of R commands
#' @param continue character, the prompt for continuation lines
#' @return Character vector holding just the clean R code, invisibly
#' @name un-reprex
NULL

#' @describeIn un-reprex Attempts to reverse the effect of [reprex()]. When
#'   `venue = "r"`, this just becomes a wrapper around `reprex_clean()`.
#' @inheritParams reprex
#' @export
#' @examples
#' \dontrun{
#' ## a rendered reprex can be inverted, at least approximately
#' tmp_in <- file.path(tempdir(), "roundtrip-input")
#' x <- reprex({
#'   #' Some text
#'   #+ chunk-label-and-options-cannot-be-recovered, message = TRUE
#'   (x <- 1:4)
#'   #' More text
#'   y <- 2:5
#'   x + y
#' }, html_preview = FALSE, advertise = FALSE, outfile = tmp_in)
#' tmp_out <- file.path(tempdir(), "roundtrip-output")
#' x <- reprex_invert(x, outfile = tmp_out)
#' x
#'
#' # clean up
#' file.remove(
#'   list.files(dirname(tmp_in), pattern = "roundtrip", full.names = TRUE)
#' )
#' }
reprex_invert <- function(input = NULL,
                          wd = NULL,
                          venue = c("gh", "r", "so", "ds"),
                          comment = opt("#>"),
                          outfile = "DEPRECATED") {
  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- ds_is_gh(venue)
  venue <- so_is_gh(venue)

  if (venue == "r") {
    return(
      reprex_clean(input, wd = wd, comment = comment, outfile = outfile))
  }

  reprex_undo(
    input,
    wd = wd,
    venue = venue,
    is_md = TRUE,
    comment = comment,
    outfile = outfile
  )
}

#' @describeIn un-reprex Assumes R code is top-level, possibly interleaved with
#'   commented output, e.g., a displayed reprex copied from GitHub or the direct
#'   output of `reprex(..., venue = "R")`. This function removes commented
#'   output.
#' @export
#' @examples
#' \dontrun{
#' ## a displayed reprex can be cleaned of commented output
#' tmp <- file.path(tempdir(), "commented-code")
#' x <- c(
#'   "## a regular comment, which is retained",
#'   "(x <- 1:4)",
#'   "#> [1] 1 2 3 4",
#'   "median(x)",
#'   "#> [1] 2.5"
#'   )
#' out <- reprex_clean(x, outfile = tmp)
#' out
#'
#' # clean up
#' file.remove(
#'   list.files(dirname(tmp), pattern = "commented-code", full.names = TRUE)
#' )
#'
#' ## round trip with reprex(..., venue = "R")
#' code_in <- c("x <- rnorm(2)", "min(x)")
#' res <- reprex(input = code_in, venue = "R", advertise = FALSE)
#' res
#' (code_out <- reprex_clean(res))
#' identical(code_in, code_out)
#' }
reprex_clean <- function(input = NULL,
                         wd = NULL,
                         comment = opt("#>"),
                         outfile = "DEPRECATED") {
  reprex_undo(input, wd = wd, is_md = FALSE, comment = comment, outfile = outfile)
}

#' @describeIn un-reprex Assumes R code lines start with a prompt and that
#'   printed output is top-level, e.g., what you'd get from copy/paste from the
#'   R Console. Removes lines of output and strips prompts from lines holding R
#'   commands.
#' @export
#' @examples
#' \dontrun{
#' ## rescue a reprex that was copied from a live R session
#' tmp <- file.path(tempdir(), "live-transcript")
#' x <- c(
#'   "> ## a regular comment, which is retained",
#'   "> (x <- 1:4)",
#'   "[1] 1 2 3 4",
#'   "> median(x)",
#'   "[1] 2.5"
#' )
#' out <- reprex_rescue(x, outfile = tmp)
#' out
#'
#' # clean up
#' file.remove(
#'   list.files(dirname(tmp),pattern = "live-transcript", full.names = TRUE)
#' )
#' }
reprex_rescue <- function(input = NULL,
                          wd = NULL,
                          prompt = getOption("prompt"),
                          continue = getOption("continue"),
                          outfile = "DEPRECATED") {
  reprex_undo(
    input,
    wd = wd,
    is_md = FALSE,
    prompt = paste(escape_regex(prompt), escape_regex(continue), sep = "|"),
    outfile = outfile
  )
}

reprex_undo <- function(input = NULL,
                        wd = NULL,
                        venue,
                        is_md = FALSE,
                        comment = NULL, prompt = NULL,
                        outfile = "DEPRECATED") {
  where <- locate_input(input)
  src <- switch(
    where,
    clipboard = ingest_clipboard(),
    path      = read_lines(input),
    input     = escape_newlines(sub("\n$", "", input)),
    selection = rstudio_selection(),
    NULL
  )
  comment <- arg_option(comment)

  # TODO: temporary arrangement so I can rough in the outfile --> wd change
  # this should really behave just like reprex() in terms of what happens
  # with output
  # writing a file should just happen and we should expose it via clipboard or
  # by opening it (+ possibly 'select all')
  # chatty = TRUE is sort of morally what we were doing here
  prex_files <- plan_files(
    infile = if (where == "path") input else NULL,
    wd = wd, outfile = outfile
  )
  outfile_given <- prex_files$chatty
  if (outfile_given) {
    r_file <- r_file_clean(prex_files$filebase)
    if (would_clobber(r_file)) {
      return(invisible())
    }
  }

  if (is_md) { ## reprex_invert
    x_out <- convert_md_to_r(src, comment = comment, drop_output = TRUE)
  } else if (is.null(prompt)) { ## reprex_clean
    x_out <- src[!grepl(comment, src)]
  } else { ## reprex_rescue
    regex <- paste0("^\\s*", prompt)
    x_out <- src[grepl(regex, src)]
    x_out <- sub(regex, "", x_out)
  }

  if (reprex_clipboard()) {
    clipr::write_clip(x_out)
    reprex_success("Clean code is on the clipboard.")
  }
  if (outfile_given) {
    write_lines(x_out, r_file)
    reprex_path("Writing clean code as {.code .R} script:", r_file)
  }
  invisible(x_out)
}

convert_md_to_r <- function(lines, comment = "#>", drop_output = FALSE) {
  lines_info <- classify_fenced_lines(lines, comment = comment)
  lines_out <- ifelse(lines_info == "prose" & nzchar(lines), roxygen_comment(lines), lines)
  drop_classes <- c("bt", if (drop_output) "output")
  lines_out[!lines_info %in% drop_classes]
}

## Classify lines in the presence of fenced code blocks.
## Specifically, blocks fenced by three backticks.
## This is true of the output from reprex(..., venue = "gh").
## Classifies each line like so:
##   * bt     = backticks
##   * code   = code inside a fenced block
##   * output = commented output inside a fenced block
##   * prose  = outside a fenced block
classify_fenced_lines <- function(x, comment = "^#>") {
  x_shift <- c("", utils::head(x, -1))
  cumulative_fences <- cumsum(grepl("^```", x_shift))
  wut <- ifelse(grepl("^```", x), "bt",
    ifelse(cumulative_fences %% 2 == 1, "code", "prose")
  )
  wut <- ifelse(wut == "code" & grepl(comment, x), "output", wut)
  wut
}
