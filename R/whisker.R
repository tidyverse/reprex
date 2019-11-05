apply_template <- function(x, reprex_data = NULL) {
  data <- with(reprex_data, list(
    venue = venue,
    advertise = advertise,
    session_info = session_info,
    comment = comment,
    tidyverse_quiet = tidyverse_quiet,
    body = collapse(x)
  ))

  if (!is.null(reprex_data$std_file)) {
    data$std_file_stub <- prose(newline(backtick(reprex_data$std_file)))
  }

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

si <- function(details = FALSE) {
  txt <- r_chunk(session_info_string())

  if (details) {
    txt <- c(
      "<details><summary>Session info</summary>",
      txt,
      "</details>"
    )
  }

  txt
}

session_info_string <- function() {
  if (rlang::is_installed("sessioninfo")) {
    "sessioninfo::session_info()"
  } else {
    "sessionInfo()"
  }
}
