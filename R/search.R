get_library_calls <- function() {
  loaded_packages <- get_loaded_packages()
  non_base_packages <- filter_base_packages(loaded_packages)
  if (length(non_base_packages) == 0) return(character())
  c(
    "# Packages already on the search path:",
    "suppressPackageStartupMessages({",
    paste0("  library(", non_base_packages, ")"),
    "})",
    "",
    "# User code:"
  )
}

get_loaded_packages <- function() {
  pkg_rx <- "^package:"
  gsub(pkg_rx, "", grep(pkg_rx, search(), value = TRUE))
}

filter_base_packages <- function(packages) {
  installed <- installed.packages()[packages, ]
  priority <- installed[, "Priority"]
  non_base <- is.na(priority) | priority != "base"
  rownames(installed)[non_base]
}
