{{{yaml}}}

{{{so_syntax_highlighting}}}

#+ reprex-setup, include = FALSE
options(tidyverse.quiet = {{{tidyverse_quiet}}})
knitr::opts_chunk$set(collapse = TRUE, comment = "{{{comment}}}", error = TRUE)
knitr::opts_knit$set(upload.fun = {{{upload_fun}}})

#+ reprex-body
{{{body}}}

{{{std_file_stub}}}

{{#advertise}}
#' Created on `r Sys.Date()` by the [reprex package](http://reprex.tidyverse.org) (v`r utils::packageVersion("reprex")`).
{{/advertise}}

{{#si}}
{{{si_start}}}
{{{si}}}
{{{si_end}}}
{{/si}}
