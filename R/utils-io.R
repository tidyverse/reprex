readLines <- function(...) {
  stop("In this house, we use read_lines() for UTF-8 reasons.")
}

writeLines <- function(...) {
  stop("In this house, we use write_lines() for UTF-8 reasons.")
}

read_lines <- function(path, n = -1L) {
  if (is.null(path)) return(NULL)
  base::readLines(path, n = n, encoding = "UTF-8", warn = FALSE)
}

write_lines <- function(text, path, sep = "\n") {
  path <- file(path, open = "wb")
  on.exit(close(path), add = TRUE)
  base::writeLines(enc2utf8(text), con = path, sep = sep, useBytes = TRUE)
}

reprex_default_filebase <- function(in_temp_dir) {
  if (in_temp_dir) {
    # outfile is NULL --> reprex in sub-directory, within session temp directory
    # example: /private/var/.../.../.../reprex97d77de2835c/reprex
    target_dir <- path_real(dir_create(file_temp("reprex")))
    path(target_dir, "reprex")
  } else {
    # infile = NULL, outfile is NA --> reprex in working directory
    # TODO: I'd love to devise a better way to express "work in current working
    # directory", i.e. I've concluded that `outfile = NA` is yucky
    # example: reprexbfa165580676
    path_file(file_temp("reprex"))
  }
}

make_filebase <- function(outfile = NULL, infile = NULL) {
  if (is.null(outfile)) {
    return(reprex_default_filebase(in_temp_dir = TRUE))
  }

  if (!is.na(outfile)) {
    return(path_ext_remove(outfile))
  }

  if (is.null(infile)) {
    return(reprex_default_filebase(in_temp_dir = FALSE))
  } else {
    ## outfile = NA, infile = "sthg" --> follow infile's lead
    ## example: basename_of_infile
    ## example: path/to/infile
    path_ext_remove(infile)
  }
}

add_suffix <- function(x, suffix = "reprex") {
  orig_ext <- path_ext(x)
  filebase <- path_ext_remove(x)
  if (nzchar(suffix)) {
    filebase <- paste0(filebase, "_", suffix)
  }
  path_ext_set(filebase, orig_ext)
}

path_mutate <- function(path, suffix = "", ext = NULL) {
  if (nzchar(suffix)) {
    path <- add_suffix(path, suffix)
  }
  if (!is.null(ext)) {
    path <- path_ext_set(path, ext)
  }
  path
}

r_file <- function(path) {
  path_mutate(path, suffix = "reprex", ext = "R")
}

r_file_clean <- function(path) {
  path_mutate(path, suffix = "clean", ext = "R")
}

r_file_rendered <- function(path) {
  path_mutate(path, suffix = "rendered", ext = "R")
}

md_file <- function(path) {
  path_mutate(path, ext = "md")
}

std_file <- function(path) {
  path_mutate(path, suffix = "std_out_err", ext = "txt")
}

html_file <- function(path) {
  path_mutate(path, suffix = "reprex", ext = "html")
}

rtf_file <- function(path) {
  path_mutate(path, ext = "rtf")
}

rmd_file <- function(path) {
  path_mutate(path, suffix = "reprex", ext = "Rmd")
}

force_tempdir <- function(path) {
  if (is_in_tempdir(path)) {
    path
  } else {
    file_copy(path, path_temp(path_file(path)), overwrite = TRUE)
  }
}

is_in_tempdir <- function(path) {
  identical(
    path_real(path_temp()),
    path_common(path_real(c(path, path_temp())))
  )
}

would_clobber <- function(path) {
  if (!file_exists(path)) {
    return(FALSE)
  }
  if (!is_interactive()) {
    return(TRUE)
  }
  nope(
    "Oops, file already exists:\n  * ", path, "\n",
    "Carry on and overwrite it?"
  )
}
