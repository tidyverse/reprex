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
#'   interpreted as the path to a file containing the reprex. Otherwise,
#'   assumed to hold the reprex as a character vector. If not provided, the
#'   clipboard is consulted for input. If the clipboard is unavailable and
#'   we're in RStudio, the current selection is used.
#' @param comment regular expression that matches commented output lines
#' @param prompt character, the prompt at the start of R commands
#' @param continue character, the prompt for continuation lines
#' @return Character vector holding just the clean R code, invisibly
#' @name un-reprex
NULL

#' @describeIn un-reprex Attempts to reverse the effect of [reprex()]. When
#'   `venue = "r"`, this just calls `reprex_clean()`.
#' @inheritParams reprex
#' @export
#' @examples
#' \dontrun{
#' # a roundtrip: R code --> rendered reprex, as gfm --> R code
#' original <- file.path(tempdir(), "original.R")
#' writeLines(glue::glue("
#'   #' Some text
#'   #+ chunk-label-and-options-cannot-be-recovered, message = TRUE
#'   (x <- 1:4)
#'   #' More text
#'   y <- 2:5
#'   x + y"), con = original)
#' reprex(input = original, html_preview = FALSE, advertise = FALSE)
#' reprexed <- sub("[.]R$", "_reprex.md", original)
#' writeLines(readLines(reprexed))
#' unreprexed <- reprex_invert(input = reprexed)
#' writeLines(unreprexed)
#'
#' # clean up
#' file.remove(
#'   list.files(dirname(original), pattern = "original", full.names = TRUE)
#' )
#' }
reprex_invert <- function(input = NULL,
                          wd = NULL,
                          venue = c("gh", "r"),
                          comment = opt("#>"),
                          outfile = "DEPRECATED") {
  venue <- tolower(venue)
  venue <- match.arg(venue)

  if (venue == "r") {
    return(
      reprex_clean(input, wd = wd, comment = comment, outfile = outfile)
    )
  }

  reprex_undo(input, wd = wd, is_md = TRUE, comment = comment, outfile = outfile)
}

#' @describeIn un-reprex Assumes R code is top-level, possibly interleaved with
#'   commented output, e.g., a displayed reprex copied from GitHub or the direct
#'   output of `reprex(..., venue = "R")`. This function removes commented
#'   output.
#' @export
#' @examples
#' \dontrun{
#' # a roundtrip: R code --> rendered reprex, as R code --> original R code
#' code_in <- c(
#'   "# a regular comment, which is retained",
#'   "(x <- 1:4)",
#'   "median(x)"
#' )
#' reprexed <- reprex(input = code_in, venue = "r", advertise = FALSE)
#' writeLines(reprexed)
#' code_out <- reprex_clean(input = reprexed)
#' writeLines(code_out)
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
#' # rescue a reprex that was copied from a live R session
#' from_r_console <- c(
#'   "> # a regular comment, which is retained",
#'   "> (x <- 1:4)",
#'   "[1] 1 2 3 4",
#'   "> median(x)",
#'   "[1] 2.5"
#' )
#' rescued <- reprex_rescue(input = from_r_console)
#' writeLines(rescued)
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

  undo_files <- plan_files(
    infile = if (where == "path") input else NULL,
    wd = wd, outfile = outfile
  )
  r_file <- r_file_clean(undo_files$filebase)
  if (would_clobber(r_file)) {
    return(invisible())
  }

  if (is_md) {                             # reprex_invert
    out <- convert_md_to_r(src, comment = comment, drop_output = TRUE)
  } else if (is.null(prompt)) {            # reprex_clean
    out <- src[!grepl(comment, src)]
  } else {                                 # reprex_rescue
    regex <- paste0("^\\s*", prompt)
    out <- src[grepl(regex, src)]
    out <- sub(regex, "", out)
  }

  if (undo_files$chatty) {
    reprex_path("Writing clean code as {.code .R} script:", r_file)
  }
  write_lines(out, r_file)
  expose_reprex_output(r_file)
  invisible(out)
}

convert_md_to_r <- function(lines, comment = "#>", drop_output = FALSE) {
  lines_info <- classify_fenced_lines(lines, comment = comment)
  lines_out <- ifelse(lines_info == "prose" & nzchar(lines), roxygen_comment(lines), lines)
  drop_classes <- c("bt", if (drop_output) "output")
  lines_out[!lines_info %in% drop_classes]
}

# Classify lines in the presence of fenced code blocks.
# Specifically, blocks fenced by three backticks.
# This is true of the output from reprex() with venue "gh" (+ "so", "ds", "slack")
# Classifies each line like so:
#   * bt     = backticks
#   * code   = code inside a fenced block
#   * output = commented output inside a fenced block
#   * prose  = outside a fenced block
classify_fenced_lines <- function(x, comment = "^#>") {
  x_shift <- c("", utils::head(x, -1))
  cumulative_fences <- cumsum(grepl("^```", x_shift))
  wut <- ifelse(grepl("^```", x), "bt",
                ifelse(cumulative_fences %% 2 == 1, "code", "prose")
  )
  wut <- ifelse(wut == "code" & grepl(comment, x), "output", wut)
  wut
}
