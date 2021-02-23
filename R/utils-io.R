readLines <- function(...) {
  abort("In this house, we use `read_lines()` for UTF-8 reasons.")
}

writeLines <- function(...) {
  abort("In this house, we use `write_lines()` for UTF-8 reasons.")
}

read_lines <- function(path, n = -1L) {
  if (is.null(path)) return(NULL)
  base::readLines(path, n = n, encoding = "UTF-8", warn = FALSE)
}

write_lines <- function(text, path, sep = "\n") {
  path <- file(path, open = "wb")
  withr::defer(close(path))
  base::writeLines(enc2utf8(text), con = path, sep = sep, useBytes = TRUE)
}

locate_input <- function(input) {
  if (is.null(input)) {
    if (reprex_clipboard()) {
      return("clipboard")
    }
    if (in_rstudio()) {
      return("selection")
    } else {
      return(NULL)
    }
  }

  if (is_path(input)) {
    "path"
  } else {
    "input"
  }
}

retrofit_files <- function(infile = NULL, wd = NULL, outfile = "DEPRECATED") {
  if (identical(outfile, "DEPRECATED")) {
    return(list(infile = infile, wd = wd))
  }
  # `outfile` was specified

  if (!is.null(wd)) {
    reprex_warning("{.code outfile} is deprecated, in favor of {.code wd}")
    return(list(infile = infile, wd = wd))
  }
  # `wd` was not specified

  # cases to consider
  # infile      outfile
  # NULL        NA
  # "foo.R"     NA
  # "foo/bar.R" NA
  # NULL        "foo"
  # NULL        "foo/bar"
  # "foo/bar.R" "blah"

  if (is.na(outfile)) {
    # historically, this was a good way to say "reprex in working directory"
    if (is.null(infile)) {
      reprex_warning("{.code outfile} is deprecated, in favor of {.code wd}")
      reprex_warning(
        'Use {.code reprex(wd = ".")} instead of {.code reprex(outfile = NA)}'
      )
      return(list(infile = NULL, wd = "."))
    }
    reprex_warning(
      "{.code outfile} is deprecated, working directory will be derived from {.code input}"
    )
    return(list(infile = infile, wd = NULL))
  }
  # `outfile` is string

  if (is.null(infile)) {
    reprex_warning("{.code outfile} is deprecated")
    reprex_warning(
      "To control output filename, provide a filepath to {.code input}"
    )
    reprex_warning("Only taking working directory from {.code outfile}")
    return(list(infile = NULL, wd = path_dir(outfile)))
  }
  # both `infile` and `outfile` are strings

  reprex_warning("{.code outfile} is deprecated")
  reprex_warning(
    "Working directory and output filename will be determined from {.code input}"
  )
  list(infile = infile, wd = NULL)
}

plan_files <- function(infile = NULL, wd = NULL, outfile = "DEPRECATED") {
  tmp <- retrofit_files(infile, wd, outfile)
  infile <- tmp$infile
  wd <- tmp$wd
  chatty <- !is.null(infile) || !is.null(wd) || !identical(outfile, "DEPRECATED")

  if (!is.null(infile) && !is.null(wd)) {
    reprex_warning(
      "Ignoring {.code wd}, working directory is determined by {.code input}"
    )
    wd <- NULL
  }

  list(
    chatty = chatty,
    filebase = make_filebase(infile, wd)
  )
}

# we'll index into the (shuffled) adjective-animal list with this
aa_i <- (function() {
  i <- 0
  function() {
    i <<- i + 1
    i
  }
})()

reprex_aa <- function() adjective_animal[[aa_i()]]

reprex_default_filebase <- function(in_temp_dir) {
  # ugly but (probably) unique
  ugly_dir <- file_temp("reprex-")
  # human-friendly and unique within an R session, at least for first n reprexes
  aa <- reprex_aa()
  if (in_temp_dir) {
    # wd not specified --> reprex in sub-directory of session temp directory
    # example: /private/var/.../.../.../reprex-98183d9c49-prior-boa/prior-boa
    target_dir <- path_real(dir_create(glue::glue("{ugly_dir}-{aa}")))
    path(target_dir, aa)
  } else {
    # no infile, wd is specified
    # example: prior-boa
    aa
  }
}

make_filebase <- function(infile = NULL, wd = NULL) {
  if (is.null(infile)) {
    if (is.null(wd)) {
      reprex_default_filebase(in_temp_dir = TRUE)
    } else {
      if (wd == ".") {
        reprex_default_filebase(in_temp_dir = FALSE)
      } else {
        path(wd, reprex_default_filebase(in_temp_dir = FALSE))
      }
    }
  } else {
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
  path_mutate(path, suffix = "r", ext = "R")
}

md_file <- function(path) {
  path_mutate(path, ext = "md")
}

md_file_slack <- function(path) {
  path_mutate(path, suffix = "slack", ext = "md")
}

std_file <- function(path) {
  path_mutate(path, suffix = "std_out_err", ext = "txt")
}

html_file <- function(path) {
  path_mutate(path, ext = "html")
}

rtf_file <- function(path) {
  path_mutate(path, ext = "rtf")
}

rmd_file <- function(path) {
  path_mutate(path, suffix = "reprex", ext = "Rmd")
}

preview_file <- function(path) {
  path_mutate(path, suffix = "preview", ext = "html")
}

would_clobber <- function(path) {
  if (!file_exists(path)) {
    return(FALSE)
  }
  if (!is_interactive()) {
    return(TRUE)
  }
  reprex_path("Oops, file already exists:", path, type = "warning")
  nope("Carry on and overwrite it?")
}

# goals in order of preference:
# 1. put reprex output on clipboard
# 2. open file for manual copy
expose_reprex_output <- function(reprex_file, rtf = FALSE) {
  if (reprex_clipboard()) {
    if (rtf && is_windows()) {
      write_clip_windows_rtf(reprex_file)
    } else {
      clipr::write_clip(read_lines(reprex_file))
    }
    reprex_success("Reprex output is on the clipboard.")
    return(invisible())
  }

  if (!is_interactive()) {
    return(invisible())
  }

  if (rtf) {
    reprex_path("Attempting to open RTF output file:", reprex_file)
    utils::browseURL(reprex_file)
    return(invisible())
  }

  reprex_path("Opening output file for manual copy:", reprex_file)
  if (in_rstudio()) {
    rstudio_open_and_select_all(reprex_file)
  } else {
    withr::defer_parent(utils::file.edit(reprex_file))
  }
  invisible()
}

rstudio_open_and_select_all <- function(path) {
  rstudioapi::navigateToFile(path)
  # navigateToFile() is not synchronous, hence the while loop & sleep
  # it takes an indeterminate amount of time for the active source file to
  # actually be 'path'
  #
  # DO NOT fiddle with this unless you also do thorough manual tests,
  # including on RSP, Cloud, using reprex() and the addin and the gadget
  ct <- rstudioapi::getSourceEditorContext()
  i <- 0
  while(ct$path == '' || path_real(ct$path) != path_real(path)) {
    if (i > 4) break
    i <- i + 1
    Sys.sleep(1)
    ct <- rstudioapi::getSourceEditorContext()
  }
  rg <- rstudioapi::document_range(
    start = rstudioapi::document_position(1, 1),
    end   = rstudioapi::document_position(Inf, Inf)
  )
  rstudioapi::setSelectionRanges(rg, id = ct$id)
  invisible()
}
