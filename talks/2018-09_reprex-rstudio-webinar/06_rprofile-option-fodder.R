#+ eval = FALSE
options(
  reprex.advertise = FALSE,
  reprex.si = TRUE,
  reprex.style = TRUE,
  reprex.comment = "#;-)",
  reprex.tidyverse_quiet = FALSE
)

#+ eval = FALSE
reprex(
  x = NULL, input = NULL, outfile = NULL,
  venue = c("gh", "so", "ds", "r", "rtf"),
  render = TRUE, advertise = NULL,
  si = opt(FALSE), style = opt(FALSE),
  show = opt(TRUE), comment = opt("#>"),
  tidyverse_quiet = opt(TRUE), std_out_err = opt(FALSE)
)
