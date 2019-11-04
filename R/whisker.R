apply_template <- function(x, reprex_data = NULL) {
  data <- with(reprex_data, list(
    tidyverse_quiet = as.character(tidyverse_quiet),
    comment = comment,
    ad = "Created on `r Sys.Date()` by the [reprex package](https://reprex.tidyverse.org) (v`r utils::packageVersion(\"reprex\")`)"
  ))

  if (!is.null(reprex_data$std_file)) {
    data$std_file_stub <- prose(newline(backtick(reprex_data$std_file)))
  }

  if (isTRUE(reprex_data$si)) {
    # TO RECONSIDER: once I am convinced that so == gh, I can eliminate the
    # `details` argument of `si()`. Empirically, there seems to be no downside
    # on SO when we embed session info in the html tags that are favorable for
    # GitHub. They apparently are ignored.
    data$si <- collapse(si(details = reprex_data$venue == "gh"))
  }

  if (reprex_data$venue %in% c("gh", "so")) {
    data$ad <- paste0("<sup>", data$ad, "</sup>")
  }

  data$ad <- if (reprex_data$advertise) prose(data$ad) else NULL
  data$body <- collapse(x)
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
  txt <- session_info_string()

  if (details) {
    txt <- c(
      prose("<details><summary>Session info</summary>"),
      txt,
      prose("</details>")
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
