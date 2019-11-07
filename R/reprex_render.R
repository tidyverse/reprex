reprex_render <- function(input,
                          html_preview = NULL) {
  yaml_opts <- get_document_options(input)
  html_preview <-
    (html_preview %||% yaml_opts[["html_preview"]] %||% is_interactive()) &&
    is_interactive()
  stopifnot(is_toggle(html_preview))
  std_path <- std_out_err_path(input, yaml_opts)

  out <- callr::r_safe(
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
    stdout = std_path,
    stderr = std_path
  )
  if (html_preview) {
    preview(input)
  }
  out
}

prex_render <- function(input,
                        html_preview = TRUE) {
  out <- rmarkdown::render(
    input,
    quiet = TRUE, envir = globalenv(), encoding = "UTF-8",
    knit_root_dir = getwd()
  )
  if (html_preview) {
    preview(input)
  }
  out
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
  md_file      <- filenames$md_file
  preview_file <- filenames$html_file
  rmarkdown::render(
    md_file,
    output_file = preview_file,
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
