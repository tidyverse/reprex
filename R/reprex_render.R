#' Render a document in a new R session
#'
#' This is a wrapper around [rmarkdown::render()] that enforces the "reprex"
#' mentality:

#' * [rmarkdown::render()] is executed in a new R session, by using
#'   [callr::r()]. The goal is to eliminate the leakage of objects, attached
#'   packages, and other aspects of session state from the current session into
#'   the rendering session.
#'
#' * Code is evaluated in the `globalenv()` of this new R session:
#'   `render(..., envir = globalenv())`. This means that method dispatch works
#'   the way most people expect it to.

#' * The input file is assumed to be UTF-8, which is a knitr requirement as of
#'   v1.24: `render(..., encoding = "UTF-8")`.
#'
#' * If the YAML frontmatter includes `std_err_out: TRUE`, standard output and
#'   error of the rendering R session are captured and injected into the result.

#'
#'
#' @param input
#' @param html_preview
#'
#' @return
#' @export
#'
#' @examples
reprex_render <- function(input,
                          html_preview = NULL) {
  yaml_opts <- get_document_options(input)
  html_preview <-
    (html_preview %||% yaml_opts[["html_preview"]] %||% is_interactive()) &&
    is_interactive()
  stopifnot(is_toggle(html_preview))
  std_file <- std_out_err_path(input, yaml_opts)

  md_file <- callr::r_safe(
    function(input) {
      options(
        keep.source = TRUE,
        rlang_trace_top_env = globalenv(),
        crayon.enabled = FALSE
      )
      rmarkdown::render(
        input,
        quiet = TRUE, envir = globalenv(), encoding = "UTF-8"
      )
    },
    args = list(input = input),
    spinner = is_interactive(),
    stdout = std_file,
    stderr = std_file
  )

  if (!is.null(std_file)) {
    ## replace "std_file" placeholder with its contents
    inject_file(md_file, std_file, tag = "standard output and standard error")
  }

  if (html_preview) {
    preview(md_file)
  }
  md_file
}

prex_render <- function(input,
                        html_preview = TRUE) {
  md_file <- rmarkdown::render(
    input,
    quiet = TRUE, envir = globalenv(), encoding = "UTF-8",
    knit_root_dir = getwd()
  )
  if (html_preview) {
    preview(input)
  }
  md_file
}

get_document_options <- function(input) {
  yaml_input <- input
  if (tolower(path_ext(input)) == "r") {
    yaml_input <- knitr::spin(input, knit = FALSE)
    on.exit(file_delete(yaml_input), add = TRUE)
  }
  yaml <- rmarkdown::yaml_front_matter(yaml_input)
  tryCatch(
    yaml[["output"]][["reprex::reprex_document"]],
    error = function(e) list()
  )
}

std_out_err_path <- function(input, opts) {
  std_out_err <- opts[["std_out_err"]]
  if (is.null(std_out_err) || !isTRUE(std_out_err)) {
    NULL
  } else {
    make_filenames(make_filebase(outfile = NA, infile = input), suffix = "")$std_file
  }
}

preview <- function(input) {
  filenames <- make_filenames(make_filebase(outfile = NA, infile = input), suffix = "")
  #md_file      <- filenames$md_file
  #preview_file <- filenames$html_file
  preview_file <- rmarkdown::render(
    input,
    #output_file = preview_file,
    clean = FALSE,
    quiet = TRUE,
    encoding = "UTF-8",
    output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
  )

  ## html must live in session temp dir in order to display within RStudio
  preview_file <- force_tempdir(preview_file)
  viewer <- getOption("viewer") %||% utils::browseURL
  viewer(preview_file)
}
