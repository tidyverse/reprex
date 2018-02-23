#' Un-render a reprex
#'
#' @description
#' Recover clean, runnable code from a reprex captured in the wild. The code is
#' returned invisibly, put on the clipboard, and possibly written to file.
#' Three different functions address various forms of wild-caught reprex.
#'
#' @param input Character. If has length one and lacks a terminating newline,
#'   interpreted as the path to a file containing reprex code. Otherwise,
#'   assumed to hold reprex code as character vector. If not provided, the
#'   clipboard is consulted for input.
#' @param outfile Optional basename for output file. When `NULL`, no file is
#'   left behind. If `outfile = "foo"`, expect an output file in current working
#'   directory named `foo_clean.R`. If `outfile = NA`, expect on output file in
#'   a location and with basename derived from `input`, if a path, or in
#'   current working directory with basename derived from [tempfile()]
#'   otherwise.
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
#' x <- reprex({
#'   #' Some text
#'   #+ chunk-label-and-options-cannot-be-recovered, message = TRUE
#'   (x <- 1:4)
#'   #' More text
#'   y <- 2:5
#'   x + y
#' }, show = FALSE, advertise = FALSE)
#' writeLines(x)
#' x <- reprex_invert(x)
#' writeLines(x)
#' }
reprex_invert <- function(input = NULL,
                          outfile = NULL,
                          venue = c("gh", "so", "ds", "r"),
                          comment = opt("#>")) {
  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- ds_is_gh(venue)

  if (venue == "r") {
    return(reprex_clean(input, outfile = outfile, comment = comment))
  }

  reprex_undo(
    input,
    outfile = outfile,
    venue = venue,
    is_md = TRUE,
    comment = comment
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
#' x <- c(
#'   "## a regular comment, which is retained",
#'   "(x <- 1:4)",
#'   "#> [1] 1 2 3 4",
#'   "median(x)",
#'   "#> [1] 2.5"
#'   )
#' out <- reprex_clean(x)
#' writeLines(out)
#'
#' ## round trip with reprex(..., venue = "R")
#' code_in <- c("x <- rnorm(2)", "min(x)")
#' res <- reprex(input = code_in, venue = "R", advertise = FALSE)
#' res
#' (code_out <- reprex_clean(res))
#' identical(code_in, code_out)
#' }
reprex_clean <- function(input = NULL,
                         outfile = NULL,
                         comment = opt("#>")) {
  reprex_undo(input, outfile = outfile, is_md = FALSE, comment = comment)
}

#' @describeIn un-reprex Assumes R code lines start with a prompt and that
#'   printed output is top-level, e.g., what you'd get from copy/paste from the
#'   R Console. Removes lines of output and strips prompts from lines holding R
#'   commands.
#' @export
#' @examples
#' \dontrun{
#' ## rescue a reprex that was copied from a live R session
#' x <- c(
#'   "> ## a regular comment, which is retained",
#'   "> (x <- 1:4)",
#'   "[1] 1 2 3 4",
#'   "> median(x)",
#'   "[1] 2.5"
#' )
#' out <- reprex_rescue(x)
#' writeLines(out)
#' }
reprex_rescue <- function(input = NULL,
                          outfile = NULL,
                          prompt = getOption("prompt"),
                          continue = getOption("continue")) {
  reprex_undo(
    input,
    outfile = outfile,
    is_md = FALSE,
    prompt = paste(escape_regex(prompt), escape_regex(continue), sep = "|")
  )
}

reprex_undo <- function(x = NULL,
                        outfile = NULL,
                        venue,
                        is_md = FALSE,
                        comment = NULL, prompt = NULL) {
  infile <- if (is_path(x)) x else NULL
  x <- ingest_input(x)
  comment <- arg_option(comment)

  outfile_requested <- !is.null(outfile)
  if (outfile_requested) {
    files <- make_filenames(make_filebase(outfile, infile), suffix = "clean")
    r_file <- files[["r_file"]]
    if (would_clobber(r_file)) {
      return(invisible())
    }
  }

  if (is_md) {
    if (identical(venue, "gh")) { ## reprex_invert
      line_info <- classify_lines_bt(x, comment = comment)
    } else {
      line_info <- classify_lines(x, comment = comment)
    }
    x_out <- ifelse(line_info == "prose" & nzchar(x), paste("#'", x), x)
    x_out <- x_out[!line_info %in% c("output", "bt", "so_header") & nzchar(x)]
    x_out <- sub("^    ", "", x_out)
  } else if (is.null(prompt)) { ## reprex_clean
    x_out <- x[!grepl(comment, x)]
  } else { ## reprex_rescue
    regex <- paste0("^\\s*", prompt)
    x_out <- x[grepl(regex, x)]
    x_out <- sub(regex, "", x_out)
  }

  if (clipboard_available()) {
    clipr::write_clip(x_out)
    message("Clean code is on the clipboard.")
  }
  if (outfile_requested) {
    writeLines(x_out, r_file)
    message("Writing clean code as R script:\n  * ", r_file)
  }
  invisible(x_out)
}

## classify_lines_bt()
## x = presumably output of reprex(..., venue = "gh"), i.e. Github-flavored
## markdown in a character vector, with backtick code blocks
## returns character vector
## calls each line of x like so:
##   * bt = backticks
##   * code = inside a backtick code block
##   * output = output inside backtick code block (line matches `comment` regex)
##   * prose = not inside a backtick code block
classify_lines_bt <- function(x, comment = "^#>") {
  x_shift <- c("", utils::head(x, -1))
  cum_bt <- cumsum(grepl("^```", x_shift))
  wut <- ifelse(grepl("^```", x), "bt",
    ifelse(cum_bt %% 2 == 1, "code", "prose")
  )
  wut <- ifelse(wut == "code" & grepl(comment, x), "output", wut)
  wut
}

## classify_lines()
## x = presumably output of reprex(..., venue = "so"), i.e. NOT Github-flavored
## markdown in a character vector, with code blocks indented with 4 spaces
## https://stackoverflow.com/editing-help
## returns character vector
## calls each line of x like so:
##   * code = inside a code block indented by 4 spaces
##   * output = output inside an indented code block (line matches `comment` regex)
##   * prose = not inside a code block
##   * so_header = special html comment for so syntax highlighting
classify_lines <- function(x, comment = "^#>") {
  comment <- sub("\\^", "^    ", comment)
  wut <- ifelse(grepl("^    ", x), "code", "prose")
  wut <- ifelse(wut == "code" & grepl(comment, x), "output", wut)

  so_special <- "<!-- language-all: lang-r -->"
  if (identical(x[1], so_special)) {
    wut[1] <- "so_header"
  }

  wut
}
