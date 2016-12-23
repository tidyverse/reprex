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
