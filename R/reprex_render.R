reprex_render <- function(input, new_session = TRUE) {
  std_path <- std_out_err_path(input)

  if (new_session) {
    callr::r_safe(
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
      spinner = interactive(),
      stdout = std_path,
      stderr = std_path
    )
  } else {
    if (!is.null(std_path)) {
      message("Must use `new_session = TRUE` to capture standard output and error.")
    }
    rmarkdown::render(
      input,
      quiet = TRUE, envir = globalenv(), encoding = "UTF-8",
      knit_root_dir = getwd()
    )
  }
}

std_out_err_path <- function(input) {
  yaml_input <- input
  if (tolower(path_ext(input)) == "r") {
    yaml_input <- knitr::spin(input, knit = FALSE)
    on.exit(file_delete(yaml_input), add = TRUE)
  }
  yaml <- rmarkdown::yaml_front_matter(yaml_input)
  std_out_err <- tryCatch(
    yaml[["output"]][["reprex::reprex_document"]][["std_out_err"]],
    error = function(e) NULL
  )
  if (is.null(std_out_err) || !isTRUE(std_out_err)) {
    NULL
  } else {
    make_filenames(make_filebase(outfile = NA, infile = input), suffix = "")$std_file
  }
}
