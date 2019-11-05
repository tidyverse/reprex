## note that all paths pass through fs and, therefore, path_tidy()
make_filebase <- function(outfile = NULL, infile = NULL) {
  if (is.null(outfile)) {
    ## work inside a new directory, within session temp directory
    target_dir <- path_real(dir_create(file_temp("reprex")))
    ## example: /private/var/.../.../.../reprex97d77de2835c/reprex
    return(path(target_dir, "reprex"))
  }

  if (!is.na(outfile)) {
    return(path_ext_remove(outfile))
  }

  if (is.null(infile)) {
    ## outfile = NA, infile = NULL --> reprex in working directory
    ## example: reprexbfa165580676
    path_file(file_temp("reprex"))
  } else {
    ## outfile = NA, infile = "sthg" --> follow infile's lead
    ## example: basename_of_infile
    ## example: path/to/infile
    path_ext_remove(infile)
  }
}

make_filenames <- function(filebase = "foo", suffix = "reprex") {
  add_suffix <- function(x, suffix = "") paste0(x, "_", suffix)

  if (nzchar(suffix)) {
    filebase <- add_suffix(filebase, suffix)
  }
  ## make this a list so I am never tempted to index with `[` instead of `[[`
  ## can cause sneaky name problems with the named list used as data for
  ## the whisker template
  list(
    r_file    = path_ext_set(filebase, "R"),
    md_file   = path_ext_set(filebase, "md"),
    rtf_file  = path_ext_set(filebase, "rtf"),
    html_fragment_file = path_ext_set(add_suffix(filebase, "fragment"), "html"),
    std_file  = path_ext_set(add_suffix(filebase, "std_out_err"), "txt"),
    rout_file = path_ext_set(add_suffix(filebase, "rendered"), "R"),
    html_file = path_ext_set(filebase, "html")
  )
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
  if (!interactive()) {
    return(TRUE)
  }
  nope(
    "Oops, file already exists:\n  * ", path, "\n",
    "Carry on and overwrite it?"
  )
}
