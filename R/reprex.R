reprex <- function(x = NULL, slug = "REPREX", venue = c("gh", "so"),
                   outfiles = NULL) {

  venue <- match.arg(venue)

  the_source <- if(is.null(x)) cb_read() else readLines(x)

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
  cb_write(readLines(md_outfile))

  tmp_html_outfile <- add_ext(tempfile(filename), ".html")
  rmarkdown::render(md_outfile, output_file = tmp_html_outfile, quiet = TRUE)

  if(!outfiles) file.remove(add_ext(filename, c("R", "md")))

  viewer <- getOption("viewer")
  if (!is.null(viewer))
    viewer(tmp_html_outfile)
  else
    utils::browseURL(tmp_html_outfile)

}
