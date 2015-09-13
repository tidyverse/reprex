construct_safeslug <- function(slug = "REPREX") {
  if(!identical(slug, "REPREX")) {
    slug <- tolower(gsub('[^A-Za-z0-9]+', '-', slug))
    slug <- gsub("^-|-$", '', slug)
  }
  slug
}

construct_filename <- function(slug = "REPREX", venue = c("gh", "so")) {
  venue <- match.arg(venue)
  slug <- construct_safeslug(slug)
  paste(Sys.Date(), slug, venue, sep = "_")
}

add_ext <- function(x, ext = "R", force = FALSE) {
  suffix <- paste0(".", ext)
  suffix_re <- paste0(suffix, "$")
  if (grep(suffix_re, x, invert = TRUE) || force) {
    paste0(x, suffix)
  } else {
    x
  }
}

construct_directory <- function(rrdir = NULL) {
  ## THIS IS JUST A STUB
  ## I HAVE BIG PLANS
  if(is.null(rrdir)) {
    rrdir <- getwd()
  }
  normalizePath(rrdir)
}
