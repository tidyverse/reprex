#' Render a document in a new R session
#'
#' @description
#' This is a wrapper around [rmarkdown::render()] that enforces the "reprex"
#' mentality. Here's a simplified version of what happens:
#' ```
#' callr::r(
#'   function(input) {
#'     rmarkdown::render(input, envir = globalenv(), encoding = "UTF-8")
#'   },
#'   args = list(input = input),
#'   spinner = is_interactive(),
#'   stdout = std_file, stderr = std_file
#' )
#' ```
#' Key features to note
#' * [rmarkdown::render()] is executed in a new R session, by using
#'   [callr::r()]. The goal is to eliminate the leakage of objects, attached
#'   packages, and other aspects of session state from the current session into
#'   the rendering session. The system and user-level `.Rprofile`s are ignored.
#' * Code is evaluated in the `globalenv()` of this new R session, which means
#'   that method dispatch works the way most people expect it to.
#' * The input file is assumed to be UTF-8, which is a knitr requirement as of
#'   v1.24.
#' * If the YAML frontmatter includes `std_err_out: TRUE`, standard output and
#'   error of the rendering R session are captured and injected into the result.
#'
#' `reprex_render()` was designed to work with the [reprex_document()] output
#' format, typically through a call to [reprex()]. `reprex_render()` may work
#' with other R Markdown output formats, but it is not well-tested.
#'
#' @param input The input file to be rendered. This can be a `.R` script or a
#'   `.Rmd` R Markdown document.
#' @inheritParams reprex
#'
#' @return The output of [rmarkdown::render()] is passed through, i.e. the path
#'   of the output file.
#' @export
#'
#' @examples
#' \dontrun{
#' reprex_render("input.Rmd")
#' }
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
    path_mutate(input, suffix = "std_out_err", ext = "txt")
  }
}

preview <- function(input) {
  preview_file <- rmarkdown::render(
    input,
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
