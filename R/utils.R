read_from_template <- function(SLUG) {
  SLUG_path <-
    system.file("templates", paste0(SLUG, ".R"), package = "reprex")
  readLines(SLUG_path)
}
