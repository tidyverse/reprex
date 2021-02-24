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
    abort("`reprex_render()` requires an input file with UTF-8 encoding")
  }
  reprex_render_impl(
    input,
    new_session = TRUE,
    html_preview = html_preview
  )
}

prex_render <- function(input,
                        html_preview = NULL) {
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

  venue   <- yaml_opts[["venue"]] %||% "gh"
  comment <- yaml_opts[["comment"]] %||% "#>"

  html_preview <-
    html_preview %||% yaml_opts[["html_preview"]] %||% is_interactive_ish()
  stopifnot(is_bool(html_preview))

  std_out_err <- new_session && (yaml_opts[["std_out_err"]] %||% FALSE)
  if (tolower(path_ext(input)) == "rmd") {
    input <- file_copy(input, rmd_file(input), overwrite = TRUE)
  }
  std_file <- std_out_err_path(input, std_out_err)

  if (new_session) {
    # if callr::r() picks up a local .Rprofile, it should be local to
    # where the the reprex work is happening, not the session where reprex()
    # was called
    withr::with_dir(
      path_dir(input),
      out <- tryCatch(
        callr::r(
          function(input) {
            rmarkdown::render(
              input,
              quiet = TRUE, envir = globalenv(), encoding = "UTF-8"
            )
          },
          args = list(input = path_file(input)),
          spinner = is_interactive(),
          stdout = if (is.null(std_file)) NULL else path_file(std_file),
          stderr = if (is.null(std_file)) NULL else path_file(std_file)
        ),
        error = function(e) e
      )
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
    md_file <- rmarkdown::render(
      input,
      quiet = TRUE, envir = globalenv(), encoding = "UTF-8",
      knit_root_dir = getwd()
    )
  }

  # we can almost use the post_processor of output_format, but sadly we cannot
  # we can't inject std_out_err until the connection to std_file is closed
  # and we can't post process until the injection is done
  reprex_file <- switch(
    venue,
    r     = pp_md_to_r(md_file, comment = comment),
    rtf   = pp_highlight(pp_md_to_r(md_file, comment = comment)),
    slack = pp_slackify(md_file),
    html  = pp_html_render(md_file),
    md_file
  )

  # also something that would naturally go in a post_processor, but can't
  # (see above)
  if (html_preview) {
    preview(md_file)
  }
  invisible(reprex_file)
}

# heavily influenced by the post_processor() function of github_document()
preview <- function(input) {
  css <- rmarkdown::pandoc_path_arg(
    path_package(
      "rmarkdown",
      "rmarkdown/templates/github_document/resources/github.css"
    )
  )
  css <- glue::glue("github-markdown-css:{css}")
  template <- rmarkdown::pandoc_path_arg(
    path_package(
      "rmarkdown",
      "rmarkdown/templates/github_document/resources/preview.html"
    )
  )
  args <- c(
    "--standalone", "--self-contained",
    "--highlight-style", "pygments",
    "--template", template,
    "--variable", css,
    "--metadata", "pagetitle=PREVIEW",
    "--quiet"
  )

  # important considerations re: HTML preview
  # 1. where it lives matters, i.e. RStudio's decision to display it within
  #    the app (vs. using an external browser) hinges on it being located below
  #    session temp dir or RMARKDOWN_PREVIEW_DIR
  # 2. best not to co-locate with input, because (a) the user really shouldn't
  #    ever see such a preview file and (b) there's the potential for confusion
  #    with the actual reprex file when `venue = "html"` (although we do use
  #    a '_preview" suffix to disambiguate)
  preview_file <- preview_file(input)
  rmarkdown::pandoc_convert(
    input = input, to = "html", from = "gfm", output = preview_file,
    options = args, verbose = FALSE
  )

  # can be interesting re: detecting how we were called and what we should
  # do re: getting the html open
  # cat("\nRSTUDIO: ", Sys.getenv("RSTUDIO", unset = NA), file = stderr())
  # cat("\n.Platform$GUI: ", .Platform$GUI, file = stderr())
  # cat("\nis_interactive(): ", is_interactive(), file = stderr())
  # cat("\nRMARKDOWN_PREVIEW_DIR: ", Sys.getenv("RMARKDOWN_PREVIEW_DIR", NA), file = stderr())
  # cat("\ntempdir(): ", tempdir(), file = stderr())
  # cat("\n")

  preview_dir <- Sys.getenv("RMARKDOWN_PREVIEW_DIR", unset = tempdir())
  preview_file <- file_move(preview_file, preview_dir)

  if (is_interactive()) {
    viewer <- getOption("viewer") %||% utils::browseURL
    viewer(preview_file)
  } else {
    # a rudimentary proxy for:
    # "hey, we got here via the 'Knit' button"
    # so, morally, the session IS still interactive
    # this magic utterance causes RStudio to preview the file because of:
    # https://github.com/rstudio/rstudio/blob/1f998005fcafe3372413e9eb0c0b0567c46056ce/src/cpp/session/modules/rmarkdown/SessionRMarkdown.cpp#L188
    cat("\nPreview created: ", preview_file, file = stderr())
  }

  invisible(preview_file)
}

# passes is_interactive() through EXCEPT for a specific set of conditions
# that are intended to detect reprex_render() executed via RStudio's "Knit"
# button
is_interactive_ish <- function() {
  if (is_interactive()) {
    return(TRUE)
  }

  Sys.getenv("RSTUDIO", unset = "0") == "1" &&
    !is.na(Sys.getenv("RMARKDOWN_PREVIEW_DIR", unset = NA))
}

reprex_document_options <- function(input) {
  yaml_input <- input
  if (tolower(path_ext(input)) == "r") {
    yaml_input <- knitr::spin(input, knit = FALSE)
    withr::defer(file_delete(yaml_input))
  }
  yaml <- rmarkdown::yaml_front_matter(yaml_input)
  tryCatch(
    yaml[["output"]][["reprex::reprex_document"]],
    error = function(e) list()
  )
}

std_out_err_path <- function(input, std_out_err) {
  if (isTRUE(std_out_err)) {
    std_file(input)
  } else {
    NULL
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
  output_lines <- read_lines(md_file(input))
  output_lines <- convert_md_to_r(output_lines, comment = comment)
  rout_file <- r_file_rendered(input)
  write_lines(output_lines, rout_file)
  rout_file
}

# used when venue is "slack"
# https://www.markdownguide.org/tools/slack/
pp_slackify <- function(input) {
  output_lines <- read_lines(md_file(input))
  output_lines <- remove_info_strings(output_lines)
  output_lines <- simplify_image_links(output_lines)
  slack_file <- md_file_slack(input)
  write_lines(output_lines, slack_file)
  slack_file
}

# remove "info strings" from opening code fences, e.g. ```r
# https://spec.commonmark.org/0.29/#info-string
remove_info_strings <- function(x) {
  sub("^```[^`]*$", "```", x, perl = TRUE)
}

# input:  ![](https://i.imgur.com/woc4vHs.png)
# output: https://i.imgur.com/woc4vHs.png
simplify_image_links <- function(x) {
  sub("(^!\\[\\]\\()(.+)(\\)$)", "\\2", x, perl = TRUE)
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
      pandoc_args = "--quiet"
    ),
    clean = FALSE,
    quiet = TRUE,
    encoding = "UTF-8"
  )
  output_file <- file_move(output_file, html_file(input))
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
