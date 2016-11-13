{{#so_syntax_highlighting}}
#'<!-- language-all: lang-r -->
{{/so_syntax_highlighting}}
#+ reprex-header, include = FALSE

#+ reprex-setup, include = FALSE
knitr::opts_chunk$set(collapse = TRUE, comment = '#>', error = TRUE)
knitr::opts_knit$set(upload.fun = knitr::imgur_upload)
{{{user_opts_chunk}}}
{{{user_opts_knit}}}
{{#chunk_tidy}}
knitr::opts_chunk$set(tidy = TRUE, tidy.opts = list(indent = 2))
{{/chunk_tidy}}

#+ reprex-body
