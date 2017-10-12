{{{yaml}}}

{{{so_syntax_highlighting}}}

#+ reprex-setup, include = FALSE
options(tidyverse.quiet = {{{tidyverse_quiet}}})
knitr::opts_chunk$set(collapse = TRUE, comment = "{{{comment}}}", error = TRUE)
knitr::opts_knit$set(upload.fun = knitr::imgur_upload)
{{{user_opts_chunk}}}
{{{user_opts_knit}}}

#+ reprex-body
{{{body}}}

{{#std_file}}
#+ include = FALSE
lines <- readLines("{{{std_file}}}")
lines <- if (length(lines) > 0) lines else "nothing written to stdout or stderr"

#' standard output and standard error
#+ std-out-err, echo = FALSE
cat(lines, sep = "\n")
{{/std_file}}

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
