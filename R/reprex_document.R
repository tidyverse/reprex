#' reprex output format
#'
#' @description
#' This is an R Markdown output format designed specifically for making
#' "reprexes", typically created via the [reprex()] function, which ultimately
#' renders the document with [reprex_render()]. It is a heavily modified version
#' of [rmarkdown::md_document()]. The arguments have different spheres of
#' influence:
#'   * `venue` potentially affects input preparation and [reprex_render()].
#'   * Add content to the primary input, prior to rendering:
#'     - `advertise`
#'     - `session_info`
#'     - `std_out_err` (also consulted by [reprex_render()])
#'   * Influence knitr package or chunk options:
#'     - `style`
#'     - `comment`
#'     - `tidyverse_quiet`
#'
#' RStudio users can create new R Markdown documents with the
#' `reprex_document()` format using built-in templates. Do
#' *File > New File > R Markdown ... > From Template* and choose one of:
#'   * reprex (minimal)
#'   * reprex (lots of features)
#'
#' Both include `knit: reprex::reprex_render` in the YAML, which causes the
#' RStudio "Knit" button to use `reprex_render()`. If you render these documents
#' yourself, you should do same.
#'
#' @inheritParams reprex
#' @inheritParams rmarkdown::md_document
#' @return An R Markdown output format to pass to [rmarkdown::render()].
#' @export
#' @examples
#' reprex_document()
reprex_document <- function(venue = c("gh", "r", "rtf", "html", "slack", "so", "ds"),

                            advertise       = NULL,
                            session_info    = opt(FALSE),
                            style           = opt(FALSE),
                            comment         = opt("#>"),
                            tidyverse_quiet = opt(TRUE),
                            std_out_err     = opt(FALSE),
                            pandoc_args = NULL) {
  venue <- tolower(venue)
  venue <- match.arg(venue)
  venue <- normalize_venue(venue)

  advertise       <- set_advertise(advertise, venue)
  session_info    <- arg_option(session_info)
  style           <- arg_option(style)
  style           <- style_requires_styler(style)
  comment         <- arg_option(comment)
  tidyverse_quiet <- arg_option(tidyverse_quiet)
  std_out_err     <- arg_option(std_out_err)

  stopifnot(is_bool(advertise), is_bool(session_info), is_bool(style))
  stopifnot(is.character(comment))
  stopifnot(is_bool(tidyverse_quiet), is_bool(std_out_err))

  opts_chunk <- list(
    # fixed defaults
    collapse = TRUE, error = TRUE,
    # explicitly exposed for user configuration
    comment = comment,
    R.options = list(
      tidyverse.quiet = tidyverse_quiet,
      tidymodels.quiet = tidyverse_quiet
    )
  )
  if (isTRUE(style)) {
    opts_chunk[["tidy"]] <- "styler"
  }
  opts_knit <- list(
    upload.fun = switch(
      venue,
      r = identity,
      knitr::imgur_upload
    )
  )

  pandoc_args <- c(
    pandoc_args,
    if (rmarkdown::pandoc_available()) "--wrap=preserve"
  )

  pre_knit <- function(input, ...) {

    # I don't know why the pre_knit hook operates on the **original** input
    # instead of the to-be-knitted (post-spinning) input, but I need to
    # operate on the latter. So I brute force the correct path.
    # This is a no-op if input starts as `.Rmd`.
    knit_input <- sub("[.]R$", ".spin.Rmd", input)
    input_lines <- read_lines(knit_input)

    input_lines <- c(rprofile_alert(venue), "", input_lines)
    input_lines <- c(reprex_opts(venue), "", input_lines)

    if (isTRUE(advertise)) {
      input_lines <- c(input_lines, "", ad(venue))
    }

    if (isTRUE(std_out_err)) {
      input_lines <- c(input_lines, "", std_out_err_stub(input, venue))
    }

    if (isTRUE(session_info)) {
      input_lines <- c(input_lines, "", si(venue))
    }

    write_lines(input_lines, knit_input)
  }

  format <- rmarkdown::output_format(
    knitr = rmarkdown::knitr_options(
      opts_knit = opts_knit,
      opts_chunk = opts_chunk
    ),
    pandoc = rmarkdown::pandoc_options(
      to = "gfm",
      from = rmarkdown::from_rmarkdown(implicit_figures = FALSE),
      ext = ".md",
      args = pandoc_args
    ),
    clean_supporting = FALSE,
    pre_knit = pre_knit,
    base_format = rmarkdown::md_document()
  )
  format
}

reprex_opts <- function(venue = "gh") {
  string <- glue::glue('
    ```{{r reprex-options, include = FALSE}}
    options(
      keep.source = TRUE,
      rlang_trace_top_env = globalenv(),
      `rlang:::force_unhandled_error` = TRUE,
      rlang_backtrace_on_error = "full",
      crayon.enabled = FALSE,
      reprex.current_venue = "{venue}"
    )
    ```')
}

rprofile_alert <- function(venue = "gh") {
  if (venue %in% c("gh", "html", "slack")) {
    fmt <- '"*Local `.Rprofile` detected at `%s`*"'
  } else { # venue %in% c("r", "rtf")
    fmt <- '"Local .Rprofile detected at %s"'
  }
  include_eval <-
    "include = file.exists('.Rprofile'), eval = file.exists('.Rprofile')"

  c(
    glue::glue("```{{r, results = 'asis', echo = FALSE, {include_eval}}}"),
    glue::glue('cat(sprintf({fmt}, normalizePath(".Rprofile")))'),
    "```"
  )
}

ad <- function(venue = "gh") {
  if (venue %in% c("gh", "html")) {
    glue::glue('
      <sup>Created on `r Sys.Date()` by the \\
      [reprex package](https://reprex.tidyverse.org) \\
      (v`r utils::packageVersion("reprex")`)</sup>')
  } else { # venue %in% c("r", "rtf", "slack")
    glue::glue('
      Created on `r Sys.Date()` by the reprex package \\
      v`r utils::packageVersion("reprex")` https://reprex.tidyverse.org')
  }
}

std_out_err_stub <- function(input, venue = "gh") {
  txt <- backtick(std_file(input))
  if (venue %in% c("gh", "html")) {
    details(txt, desc = "Standard output and standard error")
  } else { # venue %in% c("r", "rtf", "slack")
    c("#### Standard output and error", txt)
  }
}

si <- function(venue = "gh") {
  txt <- r_chunk(session_info_string())
  if (venue %in% c("gh", "html")) {
    details(txt, "Session info")
  } else { # venue %in% c("r", "rtf", "slack")
    txt
  }
}

session_info_string <- function() {
  if (rlang::is_installed("sessioninfo")) {
    "sessioninfo::session_info()"
  } else {
    "sessionInfo()"
  }
}
