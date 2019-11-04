#' ---
#' output:
#'   reprex::reprex_document:
#'     comment: "{{{comment}}}"
#' ---

#+ reprex-setup, include = FALSE
options(tidyverse.quiet = {{{tidyverse_quiet}}})
knitr::opts_knit$set(upload.fun = {{{upload_fun}}})

#+ reprex-body
{{{body}}}

{{{std_file_stub}}}

{{{ad}}}

{{{si}}}
