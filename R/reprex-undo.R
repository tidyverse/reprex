#' Un-render a reprex
#'
#' Recover clean, runnable code from a reprex captured in the wild. The code is
#' printed, returned invisibly, and written to the clipboard, if possible. Pick
#' the function that deals with your problem:
#' \itemize{
#' \item \code{reprex_invert()} handles Markdown, with code blocks indicated
#' with backticks or indentation, e.g., the direct output of
#' \code{\link{reprex}(..., venue = "gh")} or
#' \code{\link{reprex}(..., venue = "so")}.
#' \item \code{reprex_clean()} assumes R code is top-level, possibly
#' interleaved with commented output, e.g., a displayed reprex copied from
#' GitHub or the direct output of \code{\link{reprex}(..., venue = "R")}.
#' \item \code{reprex_rescue()} assumes R code lines start with a prompt and
#' printed output is top-level, e.g., what you'd get by copying from the R
#' Console.
#' }
#'
#' @param x character, holding the lines of a displayed or rendered reprex. If
#'   not provided, the clipboard is consulted for input.
#' @param comment regular expression that matches commented output lines
#' @param prompt character, the prompt at the start of R commands
#'
#' @return character vector holding just the clean R code, invisibly
#' @name un-reprex
NULL

#' @describeIn un-reprex Attempts to reverse the effect of
#'   \code{\link{reprex}()}. The input should be Markdown, presumably the output
#'   of \code{\link{reprex}()}. \code{venue} matters because, in GitHub-flavored
#'   Markdown, code blocks are placed within triple backticks. In other Markdown
#'   dialects, such as the one used on StackOverflow, code is indented by four
#'   spaces.
#' @template venue
#' @export
#' @examples
#' ## a rendered reprex can be inverted, at least approximately
#' x <- reprex({
#'   #' Some text
#'   #+ chunk-label-and-options-cannot-be-recovered, message = TRUE
#'   (x <- 1:4)
#'   #' More text
#'   y <- 2:5
#'   x + y
#' }, show = FALSE)
#' writeLines(x)
#' reprex_invert(x)
reprex_invert <- function(x = NULL, venue = c("gh", "so"), comment = "^#>") {
  venue <- match.arg(venue)
  reprex_undo(x, is_md = TRUE, venue = venue, comment = comment)
}

#' @describeIn un-reprex Removes lines of commented output from a displayed
#'   reprex, such as code copied from a GitHub issue or \code{reprex}'ed with
#'   \code{venue = "R"}.
#' @export
#' @examples
#' ## a displayed reprex can be cleaned of commented output
#' x <- c(
#'   "## a regular comment, which is retained",
#'   "(x <- 1:4)",
#'   "#> [1] 1 2 3 4",
#'   "median(x)",
#'   "#> [1] 2.5"
#'   )
#' reprex_clean(x)
#'
#' \dontrun{
#' ## round trip with reprex(..., venue = "R")
#' code_in <- c("x <- rnorm(2)", "min(x)")
#' res <- reprex(input = code_in, venue = "R")
#' res
#' (code_out <- reprex_clean(res))
#' identical(code_in, code_out)
#' }
reprex_clean <- function(x = NULL, comment = "^#>") {
  reprex_undo(x, is_md = FALSE, comment = comment)
}

#' @describeIn un-reprex Removes lines of output and strips prompts from lines
#'   holding R commands. Typical input is copy/paste from R Console.
#' @export
#' @examples
#' ## rescue a reprex that was copied from a live R session
#' x <- c(
#'   "> ## a regular comment, which is retained",
#'   "> (x <- 1:4)",
#'   "[1] 1 2 3 4",
#'   "> median(x)",
#'   "[1] 2.5"
#' )
#' reprex_rescue(x)
reprex_rescue <- function(x = NULL, prompt = getOption("prompt")) {
  reprex_undo(x, is_md = FALSE, prompt = prompt)
}

reprex_undo <- function(x = NULL, is_md = FALSE, venue,
                        comment = NULL, prompt = NULL) {
  if (is.null(x)) {
    if (clipboard_available()) {
      suppressWarnings(x <- clipr::read_clip())
    } else {
      stop("No input provided via `x` and clipboard is not available.")
    }
  }
  if (is_md) {
    if (identical(venue, "gh")) {      ## reprex_invert
      line_info <- classify_lines_bt(x, comment = comment)
    } else {
      line_info <- classify_lines(x, comment = comment)
    }
    x_out <- ifelse(line_info == "prose" & nzchar(x), paste("#'", x), x)
    x_out <- x_out[!line_info %in% c("output", "bt", "so_header") & nzchar(x)]
    x_out <- sub("^    ", "", x_out)
  } else if (is.null(prompt)) {        ## reprex_clean
    x_out <- x[!grepl(comment, x)]
  } else {                             ## reprex_rescue
    regex <- paste0("^", prompt)
    x_out <- x[grepl(regex, x)]
    x_out <- sub(regex, "", x_out)
  }
  if (clipboard_available() && length(x_out) > 0) {
    clipr::write_clip(x_out)
  }
  message(paste0(x_out, "\n"))
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
                ifelse(cum_bt %% 2 == 1, "code", "prose"))
  wut <- ifelse(wut == "code" & grepl(comment, x), "output", wut)
  wut
}

## classify_lines()
## x = presumably output of reprex(..., venue = "so"), i.e. NOT Github-flavored
## markdown in a character vector, with code blocks indented with 4 spaces
## http://stackoverflow.com/editing-help
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

  so_special <- c("<!-- language-all: lang-r -->", "<br/>", "")
  if (identical(x[1:3], so_special)) {
    wut[1:3] <- "so_header"
  }

  wut

}
