#' Render a reprex
#'
#' Given some R code on the clipboard or in a file, this function runs it via
#' \code{\link[rmarkdown]{render}}. The resulting bit of Markdown is the primary
#' output. It will be ready and waiting on the clipboard, for pasting into a
#' GitHub issue or to stackoverflow. Optionally, the R code and Markdown will be
#' left behind in files. An HTML preview will display in RStudio's Viewer pane,
#' if available, or in the default browser otherwise.
#'
#' @param x Path to \code{.R} file containing reprex code or \code{NULL}, if the
#'   code is on the clipboard
#' @param slug Evocative words that are used to create a slug for the resulting,
#'   possibly temporary, \code{.R} file. Sorry, file stuff implemented in a
#'   half-baked way at this point.
#' @param venue "gh" for GitHub or "so" for stackoverflow
#' @param outfiles Logical indicating if the \code{.R} and \code{.md} files
#'   should be left behind. Default to \code{FALSE} if code provided via
#'   clipboard and \code{TRUE} if code read from file. At this point, outfiles
#'   are deposited in current working directory, but the goal is to consult
#'   options for a place where you keep all such snippets.
#' @examples
#' \dontrun{
#' # put some code like this on the clipboard
#' # (y <- 1:4)
#' # mean(y)
#' reprex()
#' }
#' @export
reprex <- function(x = NULL, slug = "REPREX", venue = c("gh", "so"),
                   outfiles = NULL) {

  venue <- match.arg(venue)

  the_source <- if(is.null(x)) clipr::read_clip() else readLines(x)

  if(is.null(outfiles))
    outfiles <- !is.null(x)

  if(length(the_source) < 1)
    the_source <- read_from_template("BETTER_THAN_NOTHING")

  if(grepl("```", the_source[1])) {
    stop(paste("\nFirst line of putative code is:",
               the_source[1],
               "which is not going to fly.",
               "Are we going in circles?",
               "Did you perhaps just run reprex()?",
               "In that case, the clipboard now holds the *rendered* result.",
               sep = "\n"))
  }

  ## don't prepend HEADER if it's already there
  if(!grepl("reprex-header", the_source[1])) {
    HEADER <- read_from_template("HEADER")
    the_source <- c(HEADER, the_source)
  }

  filename <- construct_filename(slug = slug, venue = venue)
  x <- file.path(construct_directory(), add_ext(filename, "R"))
  writeLines(the_source, x)

  if(venue == "gh") {
    md_outfile <-
      rmarkdown::render(x, rmarkdown::md_document(variant = "markdown_github"),
                        quiet = TRUE)
  } else { # venue == "so"
    md_outfile <- rmarkdown::render(x, rmarkdown::md_document(),
                                    quiet = TRUE)
    md_safe <- readLines(md_outfile)
    writeLines(c("<!-- language: lang-r -->\n", md_safe), md_outfile)
  }
  clipr::write_clip(readLines(md_outfile))

  tmp_html_outfile <- add_ext(tempfile(filename), ".html")
  rmarkdown::render(md_outfile, output_file = tmp_html_outfile, quiet = TRUE)

  if(!outfiles) file.remove(add_ext(filename, c("R", "md")))

  viewer <- getOption("viewer")
  if (!is.null(viewer))
    viewer(tmp_html_outfile)
  else
    utils::browseURL(tmp_html_outfile)

}
