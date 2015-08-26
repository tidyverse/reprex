#' Render a reprex
#'
#' Given some R code on the clipboard, in an expression, or in a file, this function
#' runs it via
#' \code{\link[rmarkdown]{render}}. The resulting bit of Markdown is the primary
#' output. It will be ready and waiting on the clipboard, for pasting into a
#' GitHub issue or to stackoverflow. Optionally, the R code and Markdown will be
#' left behind in files. An HTML preview will display in RStudio's Viewer pane,
#' if available, or in the default browser otherwise.
#'
#' \code{reprex_} is a version of the function that takes a character vector
#' with the desired reproducibility code; \code{reprex} is a wrapper around it.
#'
#' @param x A code expression. If not given, retrieves code from the clipboard.
#'   To \code{reprex_}, given as a character vector.
#' @param infile Path to \code{.R} file containing reprex code
#' @param venue "gh" for GitHub or "so" for stackoverflow
#' @param outfile Desired stub for output .R, .md, and .HTML files for reproducible
#'   example. If NULL, keeps them in temporary files. At this point, outfiles
#'   are deposited in current working directory, but the goal is to consult
#'   options for a place where you keep all such snippets.
#' @param show Whether to show the output in a viewer (RStudio or browser)
#'
#' @examples
#' \dontrun{
#' # put some code like this on the clipboard
#' # (y <- 1:4)
#' # mean(y)
#' reprex()
#'
#' # or provide it as code in brackets:
#' reprex({y <- 1:4; mean(y)})
#'
#' # note that you can include newlines in those brackets
#' reprex({
#'   x <- 1:4
#'   y <- 2:5
#'   x + y
#' })
#' }
#'
#' @name reprex
#'
#' @export
reprex <- function(x, infile = NULL, venue = c("gh", "so"), outfile = NULL,
                   show = TRUE) {
  deparsed <- deparse(substitute(x))
  if (identical(deparsed, "")) {
    # no argument was given; use either infile or clipboard
    if (!is.null(infile)) {
      the_source <- readLines(infile)
    } else {
      the_source <- cb_read()
    }
  } else {
    if (!is.null(infile)) {
      stop("Cannot provide both expression and input file")
    }
    # adjust the deparsed expression
    the_source <- format_deparsed(deparsed)
  }

  reprex_(the_source, venue, outfile, show)
}

#' @rdname reprex
#' @export
reprex_ <- function(x, venue = c("gh", "so"), outfile = NULL,
                    show = TRUE) {
  venue <- match.arg(venue)

  if (length(x) < 1)
    x <- read_from_template("BETTER_THAN_NOTHING")

  if(grepl("```", x[1])) {
    stop(paste("\nFirst line of putative code is:",
               x[1],
               "which is not going to fly.",
               "Are we going in circles?",
               "Did you perhaps just run reprex()?",
               "In that case, the clipboard now holds the *rendered* result.",
               sep = "\n"))
  }

  ## don't prepend HEADER if it's already there
  if(!grepl("reprex-header", x[1])) {
    HEADER <- read_from_template("HEADER")
    x <- c(HEADER, x)
  }

  outfile <- if (!is.null(outfile)) { outfile } else { tempfile() }
  R_file <- add_ext(outfile, "R")

  writeLines(x, R_file)

  if(venue == "gh") {
    md_outfile <-
      rmarkdown::render(R_file, rmarkdown::md_document(variant = "markdown_github"),
                        quiet = TRUE)
  } else { # venue == "so"
    md_outfile <- rmarkdown::render(R_file, rmarkdown::md_document(),
                                    quiet = TRUE)
    md_safe <- readLines(md_outfile)
    writeLines(c("<!-- language: lang-r -->\n", md_safe), md_outfile)
  }
  output_lines <- readLines(md_outfile)
  cb_write(output_lines)

  html_outfile <- rmarkdown::render(md_outfile, quiet = TRUE)

  viewer <- getOption("viewer")

  if (!is.null(viewer) && show)
    viewer(html_outfile)
  else
    utils::browseURL(html_outfile)

  # return the string output invisibly, useful in tests
  invisible(output_lines)
}
