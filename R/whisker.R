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

## the gsub() gymnastics are to workaround this problem in roxygen2
## https://github.com/klutometis/roxygen/issues/668
yaml_md <- "
!#' ---
!#' output:
!#'   md_document
!#' ---
"
yaml_md <- gsub("!#'", "#'", trim_ws(yaml_md))

yaml_gfm <- "
!#' ---
!#' output:
!#'   md_document:
!#'     variant: markdown_github
!#' ---
"
yaml_gfm <- gsub("!#'", "#'", trim_ws(yaml_gfm))

fodder <- list(
  gh = list(
    yaml = yaml_gfm,
    si_start = "#'<details><summary>Session info</summary>",
    si_end = "#'</details>"
  ),
  so = list(
    yaml = paste0(yaml_md, "\n#'<!-- language-all: lang-r --><br/>")
  ),
  r = list(
    yaml = yaml_gfm
  )
)
