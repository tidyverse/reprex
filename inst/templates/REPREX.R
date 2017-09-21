{{{yaml}}}

#+ reprex-setup, include = FALSE
options(tidyverse.quiet = {{{tidyverse_quiet}}})
knitr::opts_chunk$set(collapse = TRUE, comment = "{{{comment}}}", error = TRUE)
knitr::opts_knit$set(upload.fun = knitr::imgur_upload)
{{{user_opts_chunk}}}
{{{user_opts_knit}}}
{{#chunk_tidy}}
knitr::opts_chunk$set(tidy = TRUE, tidy.opts = list(indent = 2))
{{/chunk_tidy}}

#+ reprex-body
{{{body}}}

{{#si}}
{{{si_start}}}
{{#devtools}}
devtools::session_info()
{{/devtools}}
{{^devtools}}
sessionInfo()
{{/devtools}}
{{{si_end}}}
{{/si}}
