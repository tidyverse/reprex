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
#'   the rendering session. Also, the system and user-level `.Rprofile`s are
#'   ignored.
#' * Code is evaluated in the `globalenv()` of this new R session, which means
#'   that method dispatch works the way most people expect it to.
#' * The input file is assumed to be UTF-8, which is a knitr requirement as of
#'   v1.24.
#' * If the YAML frontmatter includes `std_err_out: TRUE`, standard output and
#'   error of the rendering R session are captured in `std_file`, which is
#'   then injected into the rendered result.
#'
#' `reprex_render()` is designed to work with the [reprex_document()] output
#' format, typically through a call to [reprex()]. `reprex_render()` may work
#' with other R Markdown output formats, but it is not well-tested.
#'
#' @param input The input file to be rendered. This can be a `.R` script or a
#'   `.Rmd` R Markdown document.
#' @inheritParams reprex
#' @param encoding The encoding of the input file. Note that the only acceptable
#'   value is "UTF-8", which is required by knitr as of v1.24. This is exposed
#'   as an argument purely for technical convenience, relating to the "Knit"
#'   button in the RStudio IDE.
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
                          html_preview = NULL,
                          encoding = "UTF-8") {
  if (!identical(encoding, "UTF-8")) {
    stop("`reprex_render()` requires an input file with UTF-8 encoding")
  }
  reprex_render_impl(
    input,
    new_session = TRUE,
    html_preview = html_preview
  )
}

prex_render <- function(input,
                        html_preview = TRUE) {
  reprex_render_impl(
    input,
    new_session = FALSE,
    html_preview = html_preview
  )
}

reprex_render_impl <- function(input,
                               new_session = TRUE,
                               html_preview = NULL) {
  yaml_opts <- reprex_document_options(input)
  venue <- yaml_opts[["venue"]] %||% "gh"
  html_preview <-
    (html_preview %||% yaml_opts[["html_preview"]] %||% is_interactive()) &&
    is_interactive()
  stopifnot(is_toggle(html_preview))
  std_out_err <- new_session && (yaml_opts[["std_out_err"]] %||% FALSE)
  if (tolower(path_ext(input)) == "rmd") {
    input <- file_copy(input, rmd_file(input), overwrite = TRUE)
  }
  std_file <- std_out_err_path(input, std_out_err)

  opts <- list(
    keep.source = TRUE,
    rlang_trace_top_env = globalenv(),
    `rlang:::force_unhandled_error` = TRUE,
    rlang_backtrace_on_error = "full",
    crayon.enabled = FALSE,
    reprex.current_venue = venue
  )
  if (new_session) {
    out <- tryCatch(
      callr::r(
        function(input, opts) {
          options(opts)
          rmarkdown::render(
            input,
            quiet = TRUE, envir = globalenv(), encoding = "UTF-8"
          )
        },
        args = list(input = input, opts = opts),
        spinner = is_interactive(),
        stdout = std_file,
        stderr = std_file
      ),
      error = function(e) e
    )

    # reprex has crashed R
    if (inherits(out, "error")) {
      if (!inherits(out, "callr_status_error")) {
        abort(glue::glue("
          Internal error: Unhandled error from `rmarkdown::render()` in the \\
          external process"))
      }
      if (!isTRUE(std_out_err)) {
        abort(glue::glue("
          This reprex appears to crash R
          Call `reprex()` again with `std_out_err = TRUE` to get more info"))
      }
      md_lines <- c(
        "This reprex appears to crash R.",
        "See standard output and standard error for more details.",
        "",
        std_out_err_stub(input, venue %in% c("gh", "html"))
      )
      md_file <- md_file(input)
      write_lines(md_lines, md_file)
    } else {
      md_file <- out
    }

    if (!is.null(std_file)) {
      inject_file(md_file, std_file)
    }
  } else {
    withr::with_options(
      opts,
      md_file <- rmarkdown::render(
        input,
        quiet = TRUE, envir = globalenv(), encoding = "UTF-8",
        knit_root_dir = getwd()
      )
    )
  }

  reprex_file <- md_file

  if (venue %in% c("r", "rtf")) {
    reprex_file <- pp_md_to_r(input, comment = yaml_opts[["comment"]] %||% "#>")
  }

  if (venue == "rtf") {
    reprex_file <- pp_highlight(input)
  }

  if (venue == "html") {
    reprex_file <- pp_html_render(input)
  }

  # TODO: figure out how to get the "Knit" button to display a preview :(
  if (html_preview) {
    preview_file <- preview(md_file)
    invisible(structure(preview_file, reprex_file = reprex_file))
  } else {
    invisible(structure(reprex_file, reprex_file = reprex_file))
  }
}

preview <- function(input) {
  # TODO: if it's already html, don't render again?

  # we specify output_dir in order to make sure the preview html:
  # 1. lives in session temp dir (necessary in order to display within RStudio)
  # 2. is not co-located with input because, for .html, the file rendered for
  #    preview can overwrite the input file, which is the actual reprex file
  preview_file <- rmarkdown::render(
    input,
    output_dir = file_temp("reprex-preview"),
    clean = FALSE, quiet = TRUE, encoding = "UTF-8",
    output_options = if (pandoc2.0()) list(pandoc_args = "--quiet")
  )

  viewer <- getOption("viewer") %||% utils::browseURL
  viewer(preview_file)

  invisible(preview_file)
}

reprex_document_options <- function(input) {
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

std_out_err_path <- function(input, std_out_err) {
  if (is.null(std_out_err) || !isTRUE(std_out_err)) {
    NULL
  } else {
    std_file(input)
  }
}

inject_file <- function(path, inject_path) {
  regex <- glue::glue("(`)(.*)({inject_path})(`)")

  lines <- read_lines(path)
  inject_locus <- grep(regex, lines)

  # a user should never see this, but it can happen during development
  if (length(inject_locus) > 1) {
    reprex_warning("multiple placeholders for std_out_err! taking the last")
    inject_locus <- inject_locus[length(inject_locus)]
  }

  if (length(inject_locus)) {
    inject_lines <- read_lines(inject_path)
    if (length(inject_lines) == 0) {
      inject_lines <- "-- nothing to show --"
    }
    inject_lines <- c("``` sh", inject_lines, "```")
    regex <- glue::glue("(.*){regex}(.*)")
    lines <- c(
      lines[seq_len(inject_locus - 1)],
      sub(regex, "\\1", lines[inject_locus]),
      inject_lines,
      sub(regex, "\\6", lines[inject_locus]),
      lines[-seq_len(inject_locus)]
    )
    write_lines(lines, path)
  }
  path
}

# used when venue is "r" or "rtf"
pp_md_to_r <- function(input, comment = "#>") {
  rout_file <- r_file_rendered(input)
  output_lines <- read_lines(md_file(input))
  output_lines <- convert_md_to_r(output_lines, comment = comment)
  write_lines(output_lines, rout_file)
  rout_file
}

# used when venue is "rtf"
pp_highlight <- function(input) {
  rtf_file <- rtf_file(input)
  reprex_highlight(r_file_rendered(input), rtf_file)
  rtf_file
}

# used when venue is "html"
pp_html_render <- function(input) {
  output_file <- rmarkdown::render(
    md_file(input),
    output_format = rmarkdown::html_fragment(
      self_contained = FALSE,
      pandoc_args = if (pandoc2.0()) "--quiet"
    ),
    clean = FALSE,
    quiet = TRUE,
    encoding = "UTF-8"
  )
  output_file <- file_move(output_file, html_file(output_file))
  # the html_fragment() output is a bit too minimal
  # I add an encoding specification
  # I think this is positive-to-neutral for the reprex output and, if I don't,
  # viewing the fragment in the browser results in mojibake
  output_lines <- read_lines(output_file)
  output_lines <- c(
    "<head>",
    "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">",
    "</head>",
    output_lines
  )
  write_lines(output_lines, output_file)
  output_file
}
