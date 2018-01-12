## switch to a solution based on pathr::rel_path() when/if it goes to CRAN?
## the branch consists of a stem + leaves = a normalized file path
## given the branch and one leaf, what is the stem?
## input:
##    leaf =                         foo.R   (wd = /Users/jenny/rrr/reprex)
##  branch = /Users/jenny/rrr/reprex/foo.md
## output:
##  path_stem(leaf, branch) = "/Users/jenny/rrr/reprex/"
path_stem <- function(leaf, branch) {
  res <- sub(dirname2(leaf), "", dirname(branch))
  if (identical(substr(res, nchar(res), nchar(res)), .Platform$file.sep)) {
    return(res)
  }
  paste0(res, .Platform$file.sep)
}

## dirname that returns "" instead of "."
## e.g., for a file that is in working directory
dirname2 <- function(path) {
  out <- dirname(path)
  if (identical(out, ".")) {
    return("")
  }
  out
}

strip_ext <- function(x, ext = "md|r|html") {
  if (is.null(x)) return(NULL)
  if (grepl(ext, tolower(tools::file_ext(x)))) {
    tools::file_path_sans_ext(x)
  } else {
    x
  }
}

add_suffix <- function(x, suffix = "") {
  paste(x, suffix, sep = "_")
}

add_ext <- function(x, ext = "R", force = FALSE) {
  lacks_ext <- !grepl(ext, toupper(tools::file_ext(x)))
  if (lacks_ext || force) {
    paste(x, ext, sep = ".")
  } else {
    x
  }
}

make_filebase <- function(outfile = NULL, infile = NULL) {
  if (!is.null(outfile) && is.na(outfile)) {
    outfile <- infile %||% basename(tempfile())
  }
  strip_ext(outfile) %||% tempfile()
}

make_filenames <- function(filebase = "foo", suffix = "reprex") {
  filebase <- add_suffix(filebase, suffix)
  ## make this a list so I am never tempted to index with `[` instead of `[[`
  ## can cause sneaky name problems with the named list used as data for
  ## the whisker template
  out <- list(
    r_file = add_ext(filebase, "R"),
    std_file = add_ext(add_suffix(filebase, "std_out_err"), "txt"),
    rout_file = add_ext(add_suffix(filebase, "rendered"), "R"),
    html_file = add_ext(filebase, "html")
  )
  ## defensive use of "/" because Windows + this gets dropped into R code in
  ## the template
  out[["std_file"]] <- normalizePath(
    out[["std_file"]],
    winslash = "/",
    mustWork = FALSE
  )
  out
}

force_tempdir <- function(x) {
  if (identical(normalizePath(tempdir()), normalizePath(dirname(x)))) {
    return(x)
  }
  tmp_file <- file.path(tempdir(), basename(x))
  file.copy(x, tmp_file, overwrite = TRUE)
  tmp_file
}

would_clobber <- function(path) {
  if (!file.exists(path)) {
    return(FALSE)
  }
  if (!user_available()) {
    return(TRUE)
  }
  nope(
    "Oops, file already exists:\n  * ", path, "\n",
    "Carry on and overwrite it?"
  )
}
