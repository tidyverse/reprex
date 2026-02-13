# reprex output format

This is an R Markdown output format designed specifically for making
"reprexes", typically created via the
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
function, which ultimately renders the document with
[`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).
It is a heavily modified version of
[`rmarkdown::md_document()`](https://pkgs.rstudio.com/rmarkdown/reference/md_document.html).
The arguments have different spheres of influence:

- `venue` potentially affects input preparation and
  [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).

- Add content to the primary input, prior to rendering:

  - `advertise`

  - `session_info`

  - `std_out_err` (also consulted by
    [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md))

- Influence knitr package or chunk options:

  - `style`

  - `comment`

  - `tidyverse_quiet`

RStudio users can create new R Markdown documents with the
`reprex_document()` format using built-in templates. Do *File \> New
File \> R Markdown ... \> From Template* and choose one of:

- reprex (minimal)

- reprex (lots of features)

Both include `knit: reprex::reprex_render` in the YAML, which causes the
RStudio "Knit" button to use
[`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).
If you render these documents yourself, you should do same.

## Usage

``` r
reprex_document(
  venue = c("gh", "r", "rtf", "html", "slack", "so", "ds"),
  advertise = NULL,
  session_info = opt(FALSE),
  style = opt(FALSE),
  comment = opt("#>"),
  tidyverse_quiet = opt(TRUE),
  std_out_err = opt(FALSE),
  pandoc_args = NULL
)
```

## Arguments

- venue:

  Character. Must be one of the following (case insensitive):

  - "gh" for [GitHub-Flavored Markdown](https://github.github.com/gfm/),
    the default

  - "r" for a runnable R script, with commented output interleaved. Also
    useful for [Slack code
    snippets](https://slack.com/intl/en-ca/slack-tips/share-code-snippets);
    select "R" from the "Type" drop-down menu to enjoy nice syntax
    highlighting.

  - "rtf" for [Rich Text
    Format](https://en.wikipedia.org/wiki/Rich_Text_Format) (not
    supported for un-reprexing)

  - "html" for an HTML fragment suitable for inclusion in a larger HTML
    document (not supported for un-reprexing)

  - "slack" for pasting into a Slack message. Optimized for people who
    opt out of Slack's WYSIWYG interface. Go to **Preferences \>
    Advanced \> Input options** and select "Format messages with
    markup". (If there is demand for a second Slack venue optimized for
    use with WYSIWYG, please open an issue to discuss.)

  - "so" for [Stack Overflow
    Markdown](https://stackoverflow.com/editing-help#syntax-highlighting).
    Note: this is just an alias for "gh", since Stack Overflow started
    to support CommonMark-style fenced code blocks in January 2019.

  - "ds" for Discourse, e.g., [forum.posit.co](https://forum.posit.co/).
    Note: this is currently just an alias for "gh".

- advertise:

  Logical. Whether to include a footer that describes when and how the
  reprex was created. If unspecified, the option `reprex.advertise` is
  consulted and, if that is not defined, default is `TRUE` for venues
  `"gh"`, `"html"`, `"so"`, `"ds"` and `FALSE` for `"r"`, `"rtf"`,
  `"slack"`.

- session_info:

  Logical. Whether to include
  [`sessioninfo::session_info()`](https://sessioninfo.r-lib.org/reference/session_info.html),
  if available, or
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) at the end
  of the reprex. When `venue` is "gh", the session info is wrapped in a
  collapsible details tag. Read more about
  [`opt()`](https://reprex.tidyverse.org/dev/reference/reprex_options.md).

- style:

  Logical. Whether to set the knitr chunk option `tidy = "styler"`,
  which re-styles code with the [styler
  package](https://styler.r-lib.org). Read more about
  [`opt()`](https://reprex.tidyverse.org/dev/reference/reprex_options.md).

- comment:

  Character. Prefix with which to comment out output, defaults to
  `"#>"`. Read more about
  [`opt()`](https://reprex.tidyverse.org/dev/reference/reprex_options.md).

- tidyverse_quiet:

  Logical. Sets the options `tidyverse.quiet` and `tidymodels.quiet`,
  which suppress (`TRUE`, the default) or include (`FALSE`) the startup
  messages for the tidyverse and tidymodels packages. Read more about
  [`opt()`](https://reprex.tidyverse.org/dev/reference/reprex_options.md).

- std_out_err:

  Logical. Whether to append a section for output sent to stdout and
  stderr by the reprex rendering process. This can be necessary to
  reveal output if the reprex spawns child processes or
  [`system()`](https://rdrr.io/r/base/system.html) calls. Note this
  cannot be properly interleaved with output from the main R process,
  nor is there any guarantee that the lines from standard output and
  standard error are in correct chronological order. See
  [`callr::r()`](https://callr.r-lib.org/reference/r.html) for more.
  Read more about
  [`opt()`](https://reprex.tidyverse.org/dev/reference/reprex_options.md).

- pandoc_args:

  Additional command line options to pass to pandoc

## Value

An R Markdown output format to pass to
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Examples

``` r
reprex_document()
#> $knitr
#> $knitr$opts_chunk
#> $knitr$opts_chunk$dev
#> [1] "png"
#> 
#> $knitr$opts_chunk$dpi
#> [1] 96
#> 
#> $knitr$opts_chunk$fig.width
#> [1] 7
#> 
#> $knitr$opts_chunk$fig.height
#> [1] 5
#> 
#> $knitr$opts_chunk$fig.retina
#> NULL
#> 
#> $knitr$opts_chunk$collapse
#> [1] TRUE
#> 
#> $knitr$opts_chunk$error
#> [1] TRUE
#> 
#> $knitr$opts_chunk$comment
#> [1] "#>"
#> 
#> $knitr$opts_chunk$R.options
#> $knitr$opts_chunk$R.options$tidyverse.quiet
#> [1] TRUE
#> 
#> $knitr$opts_chunk$R.options$tidymodels.quiet
#> [1] TRUE
#> 
#> 
#> 
#> $knitr$opts_knit
#> $knitr$opts_knit$upload.fun
#> function (file, key = xfun::env_option("knitr.imgur.key"), ...) 
#> {
#>     xfun::upload_imgur(file, key, ..., include_xml = TRUE)
#> }
#> <bytecode: 0x5575530333e8>
#> <environment: namespace:knitr>
#> 
#> 
#> $knitr$knit_hooks
#> NULL
#> 
#> $knitr$opts_hooks
#> NULL
#> 
#> $knitr$opts_template
#> NULL
#> 
#> 
#> $pandoc
#> $pandoc$to
#> [1] "gfm-yaml_metadata_block"
#> 
#> $pandoc$from
#> [1] "markdown+autolink_bare_uris+tex_math_single_backslash-implicit_figures"
#> 
#> $pandoc$args
#> [1] "--wrap=preserve"
#> 
#> $pandoc$keep_tex
#> [1] FALSE
#> 
#> $pandoc$latex_engine
#> [1] "pdflatex"
#> 
#> $pandoc$ext
#> [1] ".md"
#> 
#> $pandoc$convert_fun
#> NULL
#> 
#> 
#> $keep_md
#> [1] FALSE
#> 
#> $clean_supporting
#> [1] FALSE
#> 
#> $df_print
#> [1] "default"
#> 
#> $pre_knit
#> function (input, ...) 
#> {
#>     knit_input <- sub("[.]R$", ".spin.Rmd", input)
#>     input_lines <- read_lines(knit_input)
#>     input_lines <- c(rprofile_alert(venue), "", input_lines)
#>     input_lines <- c(reprex_opts(venue), "", input_lines)
#>     if (isTRUE(advertise)) {
#>         input_lines <- c(input_lines, "", ad(venue))
#>     }
#>     if (isTRUE(std_out_err)) {
#>         input_lines <- c(input_lines, "", std_out_err_stub(input, 
#>             venue))
#>     }
#>     if (isTRUE(session_info)) {
#>         input_lines <- c(input_lines, "", si(venue))
#>     }
#>     write_lines(input_lines, knit_input)
#> }
#> <bytecode: 0x557552f56b70>
#> <environment: 0x557552f79b50>
#> 
#> $post_knit
#> NULL
#> 
#> $pre_processor
#> NULL
#> 
#> $intermediates_generator
#> NULL
#> 
#> $post_processor
#> NULL
#> 
#> $file_scope
#> NULL
#> 
#> $on_exit
#> function () 
#> {
#>     if (is.function(base)) 
#>         base()
#>     if (is.function(overlay)) 
#>         overlay()
#> }
#> <bytecode: 0x5575531ea428>
#> <environment: 0x5575532114d8>
#> 
#> attr(,"class")
#> [1] "rmarkdown_output_format"
```
