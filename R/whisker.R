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

## prepend with `#' ` in a separate step because
## https://github.com/klutometis/roxygen/issues/668
yaml_md <- "
---
output:
  md_document
---"
yaml_md <- trim_ws(gsub("\\n", "\n#' ", yaml_md))

yaml_gfm <- function() {
  wrap_option <- if (pandoc1.6()) "--wrap=preserve" else "--no-wrap"
  res <- whisker::whisker.render(
    data = list(wrap_option = wrap_option),
"
---
output:
  md_document:
    pandoc_args: [
      '-f', 'markdown-implicit_figures',
      '-t', 'commonmark',
      '{{{wrap_option}}}'
    ]
---
")
  trim_ws(gsub("\\n", "\n#' ", res))
}

fodder <- list(
  gh = list(
    yaml = yaml_gfm(),
    si_start = "#'<details><summary>Session info</summary>",
    si_end = "#'</details>"
  ),
  so = list(
    yaml = yaml_md,
    so_syntax_highlighting = "#'<!-- language-all: lang-r -->"
  ),
  r = list(
    yaml = yaml_gfm()
  )
)
