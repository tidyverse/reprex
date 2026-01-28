# Render a document in a new R session

This is a wrapper around
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
that enforces the "reprex" mentality. Here's a simplified version of
what happens:

    callr::r(
      function(input) {
        rmarkdown::render(input, envir = globalenv(), encoding = "UTF-8")
      },
      args = list(input = input),
      spinner = is_interactive(),
      stdout = std_file, stderr = std_file
    )

Key features to note

- [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
  is executed in a new R session, by using
  [`callr::r()`](https://callr.r-lib.org/reference/r.html). The goal is
  to eliminate the leakage of objects, attached packages, and other
  aspects of session state from the current session into the rendering
  session. Also, the system and user-level `.Rprofile`s are ignored.

- Code is evaluated in the
  [`globalenv()`](https://rdrr.io/r/base/environment.html) of this new R
  session, which means that method dispatch works the way most people
  expect it to.

- The input file is assumed to be UTF-8, which is a knitr requirement as
  of v1.24.

- If the YAML frontmatter includes `std_err_out: TRUE`, standard output
  and error of the rendering R session are captured in `std_file`, which
  is then injected into the rendered result.

`reprex_render()` is designed to work with the
[`reprex_document()`](https://reprex.tidyverse.org/dev/reference/reprex_document.md)
output format, typically through a call to
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md).
`reprex_render()` may work with other R Markdown output formats, but it
is not well-tested.

## Usage

``` r
reprex_render(input, html_preview = NULL, encoding = "UTF-8")
```

## Arguments

- input:

  The input file to be rendered. This can be a `.R` script or a `.Rmd` R
  Markdown document.

- html_preview:

  Logical. Whether to show rendered output in a viewer (RStudio or
  browser). Always `FALSE` in a noninteractive session. Read more about
  [`opt()`](https://reprex.tidyverse.org/dev/reference/reprex_options.md).

- encoding:

  The encoding of the input file. Note that the only acceptable value is
  "UTF-8", which is required by knitr as of v1.24. This is exposed as an
  argument purely for technical convenience, relating to the "Knit"
  button in the RStudio IDE.

## Value

The output of
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
is passed through, i.e. the path of the output file.

## Examples

``` r
if (FALSE) { # \dontrun{
reprex_render("input.Rmd")
} # }
```
