apply_template <- function(data = NULL) {
  if (any(grepl("#+ reprex-setup", data$body, fixed = TRUE))) {
    return(data$body)
  }
  REPREX <- read_from_template("REPREX")
  whisker::whisker.render(REPREX, data = data)
}

read_from_template <- function(SLUG) {
  SLUG_path <- system.file("templates", paste0(SLUG, ".R"),
                           package = "reprex", mustWork = TRUE)
  readLines(SLUG_path)
}
