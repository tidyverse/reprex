apply_template <- function(x, data = NULL) {
  if (data$venue == "so") {
    ## empty line between html comment re: syntax highlighting and reprex code
    x <- c("", x)
  }
  data <- c(
    fodder[[data$venue]],
    si = if (isTRUE(data$si)) .reprex[["session_info"]],
    comment = data$comment,
    upload_fun = if (data$venue == "r") "identity" else "knitr::imgur_upload",
    user_opts_chunk = prep_opts(data$opts_chunk, which = "chunk"),
    user_opts_knit = prep_opts(data$opts_knit, which = "knit"),
    tidyverse_quiet = as.character(data$tidyverse_quiet),
    std_file_stub = if (data$std_out_err) paste0("#' `", data$std_file, "`\n#'"),
    advertisement = data$advertise,
    body = paste(x, collapse = "\n")
  )
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

fodder <- list(
  gh = list(
    yaml = yaml_md("gfm"),
    si_start = "#'<details><summary>Session info</summary>",
    si_end = "#'</details>"
  ),
  so = list(
    yaml = yaml_md("md"),
    so_syntax_highlighting = "#'<!-- language-all: lang-r -->"
  ),
  r = list(
    yaml = yaml_md("gfm")
  ),
  rtf = list(
    yaml = yaml_md("gfm")
  )
)
