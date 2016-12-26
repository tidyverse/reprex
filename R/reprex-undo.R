#' Delete commented output from a reprex
#'
#' Cleans commented output out of a displayed reprex, such as code copied from a
#' GitHub issue. The clean reprex code is printed, returned invisibly, and
#' written to the clipboard, if possible.
#'
#' @param x character, holding the lines of a rendered or displayed reprex. If
#'   not provided, the clipboard is consulted for input.
#' @param comment regular expression that matches commented output lines
#'
#' @return character vector holding just the clean R code, invisibly
#' @seealso \code{\link{reprex_invert}()} if the input is actual Markdown, i.e.
#'   the direct output of \code{\link{reprex}()}.
#' @export
#'
#' @examples
#' x <- c(
#'   "## a regular comment, which is retained",
#'   "(x <- 1:4)",
#'   "#> [1] 1 2 3 4",
#'   "median(x)",
#'   "#> [1] 2.5"
#'   )
#' reprex_clean(x)
reprex_clean <- function(x = NULL, comment = "^#>") {
  reprex_undo(x, comment = comment, is_md = FALSE)
}

#' Un-render a reprex
#'
#' A crude function to recover the input of \code{\link{reprex}()} from its
#' output. Currently assumes that the target venue was GitHub, i.e. that the
#' call was \code{reprex(..., venue = "gh")} and therefore input is
#' GitHub-flavored Markdown with code in backtick blocks.
#'
#' @inherit reprex_clean
#'
#' @seealso \code{\link{reprex_clean}()} if the input is not Markdown, i.e. if
#'   it's just a rendered code chunk copied from a GitHub issue.
#' @export
#'
#' @examples
#' x <- reprex({
#'   #' Some text
#'   #+ chunk-label-and-options-cannot-be-recovered, message = TRUE
#'   (x <- 1:4)
#'   #' More text
#'   y <- 2:5
#'   x + y
#' }, show = FALSE)
#' x
#' reprex_invert(x)
reprex_invert <- function(x = NULL, comment = "^#>") {
  reprex_undo(x, comment = comment, is_md = TRUE)
}

reprex_undo <- function(x, comment, is_md = FALSE) {
  if (is.null(x)) {
    if (clipboard_available()) {
      suppressWarnings(x <- clipr::read_clip())
    } else {
      stop("No input provided via `x` and clipboard is not available.")
    }
  }
  if (is_md) {
    line_info <- classify_lines(x, comment = comment)
    x_out <- ifelse(line_info == "prose" & nzchar(x), paste("#'", x), x)
    x_out <- x_out[!line_info %in% c("output", "bt") & nzchar(x)]
  } else {
    x_out <- x[!grepl(comment, x)]
  }
  if (clipboard_available() && length(x_out) > 0) {
    clipr::write_clip(x_out)
  }
  cat(x_out, sep = "\n")
  invisible(x_out)
}

## classify_lines()
## x = presumably output of reprex(..., venue = "gh"), i.e. Github-flavored
## markdown in a character vector
## returns character vector
## calls each line of x like so:
##   * bt = backticks
##   * fenced = inside a fenced code block
##   * output = output inside fenced code block (line matches `comment` regex)
##   * prose = not inside a fenced code block
classify_lines <- function(x, comment = "^#>") {
  x_shift <- c("", utils::head(x, -1))
  cum_bt <- cumsum(grepl("^```", x_shift))
  wut <- ifelse(grepl("^```", x), "bt",
                ifelse(cum_bt %% 2 == 1, "fenced", "prose"))
  wut <- ifelse(wut == "fenced" & grepl(comment, x), "output", wut)
  wut
}
