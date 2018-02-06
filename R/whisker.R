apply_template <- function(data = NULL) {
  if (any(grepl("#+ reprex-setup", data$body, fixed = TRUE))) {
    return(data$body)
  }
  REPREX <- read_from_template("REPREX")
  whisker::whisker.render(REPREX, data = data)
}

read_from_template <- function(SLUG) {
  SLUG_path <- system.file(
    "templates",
    add_ext(SLUG, "R"),
    package = "reprex",
    mustWork = TRUE
  )
  readLines(SLUG_path)
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
    if (pandoc_version < "1.16") {
    "      --no-wrap"
    } else {
    "      --wrap=preserve"
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
    so_syntax_highlighting = "#'<!-- language-all: lang-r -->\\n"
  ),
  r = list(
    yaml = yaml_md("gfm")
  )
)
