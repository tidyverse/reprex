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

## leave the "#' ---" lines in the template, because
## https://github.com/klutometis/roxygen/issues/668
yaml_md <- trim_ws("
#' output:
#'   md_document
")

yaml_gfm <- trim_ws("
#' output:
#'   md_document:
#'     variant: markdown_github
")

fodder <- list(
  gh = list(
    yaml = yaml_gfm,
    si_start = "#'<details><summary>Session info</summary>",
    si_end = "#'</details>"
  ),
  so = list(
    yaml = yaml_md,
    so_syntax_highlighting = "#'<!-- language-all: lang-r --><br/>"
  ),
  r = list(
    yaml = yaml_gfm
  )
)
