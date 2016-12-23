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

strip_ext <- function(x, ext = "md") {
  if (is.null(x)) return(NULL)
  if (grepl(ext, tools::file_ext(x))) {
    tools::file_path_sans_ext(x)
  } else {
    x
  }
}

add_ext <- function(x, ext = "R", force = FALSE) {
  lacks_ext <- !grepl(ext, tools::file_ext(x), ignore.case = TRUE)
  if (lacks_ext || force) {
    paste(x, ext, sep = ".")
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
