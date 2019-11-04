#' ---
#' output:
#'   reprex::reprex_document:
#'     comment: "{{{comment}}}"
#'     tidyverse_quiet: {{{tidyverse_quiet}}}
#' ---

#+ reprex-setup, include = FALSE
knitr::opts_knit$set(upload.fun = {{{upload_fun}}})

#+ reprex-body
{{{body}}}

{{{std_file_stub}}}

{{{ad}}}

{{{si}}}
