reprex_impl <- function(x_expr = NULL,
                        input  = NULL,
                        wd     = NULL,
                        venue  = c("gh", "r", "rtf", "html", "slack", "so", "ds"),

                        render = TRUE,
                        new_session = TRUE,

                        advertise       = NULL,
                        session_info    = opt(FALSE),
                        style           = opt(FALSE),
                        comment         = opt("#>"),
                        tidyverse_quiet = opt(TRUE),
                        std_out_err     = opt(FALSE),
                        html_preview    = opt(TRUE),

                        outfile = "DEPRECATED") {

  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- normalize_venue(venue)

  advertise       <- set_advertise(advertise, venue)
  session_info    <- arg_option(session_info)
  style           <- arg_option(style)
  style           <- style_requires_styler(style)
  html_preview    <- arg_option(html_preview)
  html_preview    <- html_preview_requires_interactive(html_preview)
  comment         <- arg_option(comment)
  tidyverse_quiet <- arg_option(tidyverse_quiet)
  std_out_err     <- arg_option(std_out_err)

  if (!is.null(input)) stopifnot(is.character(input))
  if (!is.null(wd)) stopifnot(is_string(wd))
  stopifnot(is_bool(advertise), is_bool(session_info), is_bool(style))
  stopifnot(is_bool(html_preview), is_bool(render))
  stopifnot(is.character(comment))
  stopifnot(is_bool(tidyverse_quiet), is_bool(std_out_err))

  if (!is.null(outfile)) stopifnot(is.character(outfile) || is.na(outfile))

  where <- if (is.null(x_expr)) locate_input(input) else "expr"
  src <- switch(
    where,
    expr      = stringify_expression(x_expr),
    clipboard = ingest_clipboard(),
    path      = read_lines(input),
    input     = escape_newlines(sub("\n$", "", enc2utf8(input))),
    selection = rstudio_selection(),
    NULL
  )
  src <- ensure_not_empty(src)
  src <- ensure_not_dogfood(src)
  src <- ensure_no_prompts(src)

  reprex_files <- plan_files(
    infile = if (where == "path") input else NULL,
    wd = wd, outfile = outfile
  )

  r_file <- r_file(reprex_files$filebase)
  if (would_clobber(r_file)) {
    return(invisible())
  }

  reprex_document_options <- list(
    venue = venue,
    advertise = advertise, session_info = session_info,
    style = style, comment = comment,
    tidyverse_quiet = tidyverse_quiet, std_out_err = std_out_err
  )
  src <- c(yamlify(reprex_document_options), "", src)
  if (reprex_files$chatty) {
    reprex_path("Preparing reprex as {.code .R} file:", r_file)
  }
  write_lines(src, r_file)

  if (!render) {
    return(invisible(read_lines(r_file)))
  }

  local_rprofile <- path(path_dir(path_real(r_file)), ".Rprofile")
  if (file_exists(local_rprofile)) {
    reprex_path(
      "Local {.code .Rprofile} detected in reprex directory:",
      local_rprofile,
      type = "warning"
    )
  }

  reprex_info("Rendering reprex...")
  reprex_file <-reprex_render_impl(
    r_file, new_session = new_session, html_preview = html_preview
  )

  if (reprex_files$chatty) {
    # TODO: be smarter about when to report full path vs. relative,
    # i.e., consider if the user provided any path info
    reprex_path("Writing reprex file:", reprex_file)
  }
  expose_reprex_output(reprex_file, rtf = (venue == "rtf"))
  invisible(read_lines(reprex_file))
}

advertise_default <- function(venue) {
  default <- c(
    gh    = TRUE,
    ds    = TRUE,
    html  = TRUE,
    so    = TRUE,
    r     = FALSE,
    rtf   = FALSE,
    slack = FALSE
  )
  default[[venue]]
}

set_advertise <- function(advertise, venue) {
  advertise %||%
    getOption("reprex.advertise") %||%
    advertise_default(venue)
}

style_requires_styler <- function(style) {
  if (!requireNamespace("styler", quietly = TRUE)) {
    reprex_danger("
      Install the {.pkg styler} package in order to use
      {.code style = TRUE}.")
    style <- FALSE
  }
  invisible(style)
}

html_preview_requires_interactive <- function(html_preview) {
  if (html_preview && !is_interactive()) {
    reprex_info(
      "Non-interactive session, setting {.code html_preview = FALSE}.")
    html_preview <- FALSE
  }
  invisible(html_preview)
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
    # this is the only conditional default, i.e. that depends on venue
    advertise       = advertise_default(x[["venue"]]),
    session_info    = FALSE,
    style           = FALSE,
    comment         = "#>",
    tidyverse_quiet = TRUE,
    std_out_err     = FALSE
  )

  compare_one <- function(nm) identical(x[[nm]], defaults[[nm]])
  is_default <- vapply(names(x), compare_one, logical(1))

  novel_names <- setdiff(names(x), names(defaults))
  if (length(novel_names) > 0) {
    reprex_danger("
      {?This/These} parameter{?s} {?is/are} not recognized for the
      {.fun reprex_document} format: {.code {novel_names}}.")
  }

  x[!is_default]
}

nv <- function(x) {
  is_character <- vapply(x, is.character, logical(1))
  # dQuote didn't gain the `q` argument until R 3.6
  withr::local_options(list(useFancyQuotes = FALSE))
  x[is_character] <- vapply(x[is_character], dQuote, character(1))
  glue::glue("{name}: {value}", name = names(x), value = x)
}
