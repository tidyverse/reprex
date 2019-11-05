apply_template <- function(x, reprex_data = NULL) {
  data <- with(reprex_data, list(
    venue = venue,
    advertise = advertise,
    session_info = session_info,
    comment = comment,
    tidyverse_quiet = tidyverse_quiet,
    std_out_err = std_out_err,
    body = collapse(x)
  ))
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


