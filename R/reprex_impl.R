reprex_impl <- function(x_expr = NULL,
                        input  = NULL, outfile = NULL,
                        venue  = c("gh", "r", "rtf", "html", "so", "ds"),

                        render = TRUE,
                        new_session = TRUE,

                        advertise       = NULL,
                        session_info    = opt(FALSE),
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
    getOption("reprex.advertise") %||% (venue %in% c("gh", "html"))
  session_info    <- arg_option(session_info)
  style           <- arg_option(style)
  show            <- arg_option(show)
  comment         <- arg_option(comment)
  tidyverse_quiet <- arg_option(tidyverse_quiet)
  std_out_err     <- arg_option(std_out_err)

  if (!is.null(input)) stopifnot(is.character(input))
  if (!is.null(outfile)) stopifnot(is.character(outfile) || is.na(outfile))
  stopifnot(is_toggle(advertise), is_toggle(session_info), is_toggle(style))
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

  format_params <- list(
    venue = venue,
    advertise = advertise, session_info = session_info, comment = comment,
    tidyverse_quiet = tidyverse_quiet, std_out_err = std_out_err
  )
  src <- c(yamlify(format_params), "", src)
  write_lines(src, r_file)
  if (outfile_given) {
    message("Preparing reprex as .R file:\n  * ", r_file)
  }

  if (!render) {
    return(invisible(read_lines(r_file)))
  }

  message("Rendering reprex...")
  reprex_render(r_file, new_session)
  ## 1. when venue = "r" or "rtf", the reprex_file != md_file, so we need both
  ## 2. use our own "md_file" instead of the normalized, absolutized path
  ##    returned by rmarkdown::render() and, therefore, reprex_render()
  reprex_file <- md_file <- files[["md_file"]]

  if (std_out_err) {
    ## replace "std_file" placeholder with its contents
    inject_file(md_file, files[["std_file"]], tag = "standard output and standard error")
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

# re-express reprex() args as yaml for the reprex_document() format ----
yamlify <- function(x) {
  x <- remove_defaults(x)
  if (length(x) < 1) {
    return(decorate_yaml("output: reprex::reprex_document"))
  }
  lines <- c(
    "output:",
    "  reprex::reprex_document:",
    paste0("    ", nv(x))
  )
  decorate_yaml(lines)
}

decorate_yaml <- function(x) roxygen_comment(x <- c("---", x, "---"))

remove_defaults <- function(x) {
  defaults <- list(
    venue           = "gh",
    advertise       = TRUE,
    session_info    = FALSE,
    comment         = "#>",
    tidyverse_quiet = TRUE,
    std_out_err     = FALSE
  )

  compare_one <- function(nm) identical(x[[nm]], defaults[[nm]])
  is_default <- vapply(names(x), compare_one, logical(1))

  novel_names <- setdiff(names(x), names(defaults))
  if (length(novel_names) > 0) {
    novel_names <- glue::glue_collapse(novel_names, sep = ", ")
    message(
      "These parameter(s) are not recognized for the `reprex_document()` format:\n",
      novel_names
    )
  }

  x[!is_default]
}

nv <- function(x) {
  is_character <- vapply(x, is.character, logical(1))
  x[is_character] <- vapply(x[is_character], dQuote, character(1), q = FALSE)
  glue::glue("{name}: {value}", name = names(x), value = x)
}