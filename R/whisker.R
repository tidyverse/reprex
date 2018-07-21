apply_template <- function(x, reprex_data = NULL) {
  data <- with(reprex_data, list(
    yaml = yaml_md("gfm"),
    tidyverse_quiet = as.character(tidyverse_quiet),
    comment = comment,
    upload_fun = "knitr::imgur_upload",
    advertise = advertise
  ))

  if (!is.null(reprex_data$std_file)) {
    data$std_file_stub <- paste0("#' `", reprex_data$std_file, "`\n#'")
  }

  if (isTRUE(reprex_data$si)) {
    if (requireNamespace("devtools", quietly = TRUE)) {
      data$si <- "devtools::session_info()"
    } else {
      data$si <- "sessionInfo()"
    }
  }

  if (reprex_data$venue == "gh") {
    data$si_start <- "#'<details><summary>Session info</summary>"
    data$si_end   <- "#'</details>"
  }

  if (reprex_data$venue == "so") {
    data$yaml <- yaml_md("md")
    data$so_syntax_highlighting <- "#'<!-- language-all: lang-r -->"
    ## empty line between html comment re: syntax highlighting and reprex code
    x <- c("", x)
  }

  if (reprex_data$venue == "r") {
    data$upload_fun <- "identity"
  }

  data$body <- paste(x, collapse = "\n")
  whisker::whisker.render(read_template("REPREX"), data = data)
}

read_template <- function(slug) {
  path <- system.file(
    "templates",
    path_ext_set(slug, "R"),
    package = "reprex",
    mustWork = TRUE
  )
  readLines(path)
}

yaml_md <- function(flavor = c("gfm", "md"),
                    pandoc_version = rmarkdown::pandoc_version()) {
  flavor <- match.arg(flavor)
  yaml <- c(
    "---",
    "output:",
    "  md_document:",
    "    pandoc_args: [",
    if (flavor == "gfm") {
      c("      '-f', 'markdown-implicit_figures',",
        "      '-t', 'commonmark',")
    },
    if (!is.null(pandoc_version)) {
      if (pandoc_version < "1.16") {
        "      --no-wrap"
      } else {
        "      --wrap=preserve"
      }
    },
    "    ]",
    "---"
  )
  ## prepend with `#' ` in a separate step because
  ## https://github.com/klutometis/roxygen/issues/668
  paste0("#' ", yaml, collapse = "\n")
}
