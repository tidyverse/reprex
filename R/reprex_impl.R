reprex_impl <- function(x_expr = NULL,
                        input  = NULL, outfile = NULL,
                        venue  = c("gh", "r", "rtf", "html", "so", "ds", "jira"),

                        render = TRUE,
                        new_session = TRUE,

                        advertise       = NULL,
                        si              = opt(FALSE),
                        style           = opt(FALSE),
                        show            = opt(TRUE),
                        comment         = opt("#>"),
                        tidyverse_quiet = opt(TRUE),
                        std_out_err     = opt(FALSE)) {

  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- ds_is_gh(venue)
  venue <- so_is_gh(venue)
  venue <- rtf_requires_highlight(venue)

  advertise       <- advertise %||%
    getOption("reprex.advertise") %||% (venue %in% c("gh", "html", "jira"))
  si              <- arg_option(si)
  style           <- arg_option(style)
  show            <- arg_option(show)
  comment         <- arg_option(comment)
  tidyverse_quiet <- arg_option(tidyverse_quiet)
  std_out_err     <- arg_option(std_out_err)

  if (!is.null(input)) stopifnot(is.character(input))
  if (!is.null(outfile)) stopifnot(is.character(outfile) || is.na(outfile))
  stopifnot(is_toggle(advertise), is_toggle(si), is_toggle(style))
  stopifnot(is_toggle(show), is_toggle(render))
  stopifnot(is.character(comment))
  stopifnot(is_toggle(tidyverse_quiet), is_toggle(std_out_err))

  where <- if (is.null(x_expr)) locate_input(input) else "expr"
  src <- switch(
    where,
    expr      = stringify_expression(x_expr),
    clipboard = ingest_clipboard(),
    path      = read_lines(input),
    input     = escape_newlines(sub("\n$", "", enc2utf8(input))),
    NULL
  )
  src <- ensure_not_empty(src)
  src <- ensure_not_dogfood(src)
  src <- ensure_no_prompts(src)
  if (style) {
    src <- ensure_stylish(src)
  }

  outfile_given <- !is.null(outfile)
  infile <- if (where == "path") input else NULL
  files <- make_filenames(make_filebase(outfile, infile))

  r_file <- files[["r_file"]]
  if (would_clobber(r_file)) { return(invisible()) }
  std_file <- if (std_out_err) files[["std_file"]] else NULL

  data <- list(
    venue = venue, advertise = advertise, si = si,
    comment = comment, tidyverse_quiet = tidyverse_quiet, std_file = std_file
  )
  src <- apply_template(src, data)
  write_lines(src, r_file)
  if (outfile_given) {
    message("Preparing reprex as .R file:\n  * ", r_file)
  }

  if (!render) {
    return(invisible(read_lines(r_file)))
  }

  message("Rendering reprex...")
  reprex_render(r_file, std_file, new_session)
  ## 1. when venue = "r", "rtf" or "jira" the reprex_file != md_file, so we need both
  ## 2. use our own "md_file" instead of the normalized, absolutized path
  ##    returned by rmarkdown::render() and, therefore, reprex_render()
  reprex_file <- md_file <- files[["md_file"]]

  if (std_out_err) {
    ## replace "std_file" placeholder with its contents
    inject_file(md_file, std_file, tag = "standard output and standard error")
  }

  if (outfile_given) {
    message("Writing reprex markdown:\n  * ", md_file)
  }

  if (venue %in% c("r", "rtf")) {
    rout_file <- files[["rout_file"]]
    output_lines <- read_lines(md_file)
    output_lines <- convert_md_to_r(output_lines, comment = comment)
    write_lines(output_lines, rout_file)
    if (outfile_given) {
      message("Writing reprex as commented R script:\n  * ", rout_file)
    }
    reprex_file <- rout_file
  }

  if (venue == "rtf") {
    rtf_file <- files[["rtf_file"]]
    reprex_highlight(reprex_file, rtf_file)
    if (outfile_given) {
      message("Writing reprex as highlighted RTF:\n  * ", reprex_file)
    }
    reprex_file <- rtf_file
  }

  if (venue == "jira") {
    jira_file <-  files[["jira_file"]]
    # jira support for pandoc conversion was added in version 2.7.3
    if (!rmarkdown::pandoc_available("2.7.3")) {
      stop(
        "Pandoc version ", rmarkdown::pandoc_version(), " is found.\n",
        "`venue = \"jira\"` requires pandoc 2.7.3 or later.",
        call. = FALSE
      )
    }
    rmarkdown::pandoc_convert(md_file, to = "jira", output = jira_file)
    reprex_file <- jira_file
  }

  if (venue == "html") {
    html_fragment_file <- files[["html_fragment_file"]]
    rmarkdown::render(
      md_file,
      output_format = rmarkdown::html_fragment(self_contained = FALSE),
      output_file = html_fragment_file,
      clean = FALSE,
      quiet = TRUE,
      encoding = "UTF-8",
      output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
    )
    reprex_file <- html_fragment_file
  }

  if (show) {
    html_file <- files[["html_file"]]
    rmarkdown::render(
      md_file,
      output_file = html_file,
      clean = FALSE,
      quiet = TRUE,
      encoding = "UTF-8",
      output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
    )

    ## html must live in session temp dir in order to display within RStudio
    html_file <- force_tempdir(html_file)
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(html_file)
  }

  out_lines <- read_lines(reprex_file)

  if (clipboard_available()) {
    clipr::write_clip(out_lines)
    message("Rendered reprex is on the clipboard.")
  } else if (interactive()) {
    clipr::dr_clipr()
    message(
      "Unable to put result on the clipboard. How to get it:\n",
      "  * Capture what `reprex()` returns.\n",
      "  * Consult the output file. Control via `outfile` argument.\n",
      "Path to `outfile`:\n",
      "  * ", reprex_file
    )
    if (yep("Open the output file for manual copy?")) {
      withr::defer(utils::file.edit(reprex_file))
    }
  }

  invisible(out_lines)
}

reprex_render <- function(input, std_out_err = NULL, new_session = TRUE) {
  if (new_session) {
    callr::r_safe(
      function(input) {
        options(
          keep.source = TRUE,
          rlang_trace_top_env = globalenv(),
          crayon.enabled = FALSE
        )
        rmarkdown::render(input, quiet = TRUE, envir = globalenv(), encoding = "UTF-8")
      },
      args = list(input = input),
      spinner = interactive(),
      stdout = std_out_err,
      stderr = std_out_err
    )
  } else {
    rmarkdown::render(
      input, quiet = TRUE,
      envir = globalenv(), knit_root_dir = getwd(),
      encoding = "UTF-8"
    )
  }
}
