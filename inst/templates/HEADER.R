{{#gh}}
#' ---
#' output:
#'   md_document:
#'     variant: markdown_github
#' ---
{{/gh}}
{{#so}}
#' ---
#' output:
#'   md_document
#' ---
#'<!-- language-all: lang-r --><br/>
{{/so}}

#+ reprex-setup, include = FALSE
knitr::opts_chunk$set(collapse = TRUE, comment = "{{{comment}}}", error = TRUE)
knitr::opts_knit$set(upload.fun = knitr::imgur_upload)
{{{user_opts_chunk}}}
{{{user_opts_knit}}}
{{#chunk_tidy}}
knitr::opts_chunk$set(tidy = TRUE, tidy.opts = list(indent = 2))
{{/chunk_tidy}}

#+ reprex-body
