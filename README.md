# reprex <img src="man/figures/logo.png" align="right" height="139" />

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/reprex)](https://cran.r-project.org/package=reprex)
[![Travis-CI Build
Status](https://travis-ci.org/tidyverse/reprex.svg?branch=master)](https://travis-ci.org/tidyverse/reprex)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/tidyverse/reprex?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/reprex)
[![Coverage
status](https://codecov.io/gh/tidyverse/reprex/branch/master/graph/badge.svg)](https://codecov.io/github/tidyverse/reprex?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)

## Overview

Prepare reprexes for posting to [GitHub
issues](https://guides.github.com/features/issues/),
[StackOverflow](https://stackoverflow.com/questions/tagged/r), or [Slack
snippets](https://get.slack.help/hc/en-us/articles/204145658-Create-a-snippet).
What is a `reprex`? It’s a **repr**oducible **ex**ample, as coined by
[Romain
Francois](https://twitter.com/romain_francois/status/530011023743655936).

<a href="https://nypdecider.files.wordpress.com/2014/08/help-me-help-you.gif"><img src="man/figures/help-me-help-you.png" align="right" /></a>

Given R code on the clipboard, selected in RStudio, as an expression
(quoted or not), or in a file …

  - run it via `rmarkdown::render()`,
  - with deliberate choices re: `render()` arguments, knitr options, and
    Pandoc options.

Get resulting runnable code + output as

  - Markdown, suitable for GitHub or Stack Overflow, or as
  - R code, augmented with commented output.

Result is returned invisibly, placed on the clipboard, and written to a
file. Preview an HTML version in RStudio viewer or default browser.

## Installation

Install from CRAN:

``` r
install.packages("reprex")
```

or get a development version from GitHub:

``` r
devtools::install_github("tidyverse/reprex")
```

On Linux, you probably want to install
[xclip](https://github.com/astrand/xclip) or
[xsel](http://www.vergenet.net/~conrad/software/xsel/), so reprex can
access the X11 clipboard. This is 'nice to have', but not mandatory. The
usual `sudo apt-get install` or `sudo yum install` installation methods
should work for both xclip and xsel.

## Usage

Let’s say you copy this code onto your clipboard:

    (y <- 1:4)
    mean(y)

Then call `reprex()`, where the default target venue is GitHub:

``` r
reprex()
```

A nicely rendered HTML preview will display in RStudio's Viewer (if
you’re in RStudio) or your default browser otherwise.

![](man/figures/README-viewer-screenshot.png)

The relevant bit of CommonMark Markdown is ready to be pasted from
your clipboard:

    ``` r
    (y <- 1:4)
    #> [1] 1 2 3 4
    mean(y)
    #> [1] 2.5
    ```

Here’s what that Markdown would look like rendered in a GitHub issue:

``` r
(y <- 1:4)
#> [1] 1 2 3 4
mean(y)
#> [1] 2.5
```

Anyone else can copy, paste, and run this immediately.

In addition to GitHub, this markdown also works on Stack Overflow and Discourse. Those venues can be formally requested via `venue = "so"` and `venue = "ds"`, but they are just aliases for `venue = "gh"`.

Instead of reading from the clipboard, you can:

  - `reprex(mean(rnorm(10)))` to get code from expression.

  - `reprex(input = "mean(rnorm(10))\n")` gets code from character
    vector (detected via length or terminating newline). Leading prompts
    are stripped from input source: `reprex(input = "> median(1:3)\n")`
    produces same output as `reprex(input = "median(1:3)\n")`

  - `reprex(input = "my_reprex.R")` gets code from file

  - Use one of the RStudio add-ins to use the selected text or current
    file.

But wait, there’s more\!

  - Get a runnable R script, augmented with commented output, with
    `reprex(..., venue = "R")`. This is useful for Slack, email, etc.

  - Get html with `reprex(..., venue = "html")`. Useful for sites that don't
    support markdown.

  - Prepare rendered, syntax-highlighted code snippets to paste into
    Keynote or PowerPoint, with `reprex(..., venue = "rtf")`. This
    feature is still experimental; see the [associated article](https://reprex.tidyverse.org/articles/articles/rtf.html) for more.

  - By default, figures are uploaded to [imgur.com](http://imgur.com)
    and the resulting URL is dropped into an inline image tag.

  - Use the `outfile` argument to control where results are left behind.
    Use `outfile = NA` to work in current working directory.
    
  - Append session info via `reprex(..., session_info = TRUE)`.

  - Get clean, runnable code from wild-caught reprexes with
    
      - `reprex_invert()` = the opposite of `reprex()`
      - `reprex_clean()`, e.g. when you copy/paste from GitHub or Stack
        Overflow
      - `reprex_rescue()`, when you’re dealing with copy/paste from R
        Console

Please note that the 'reprex' project is released with a [Contributor Code of Conduct](https://reprex.tidyverse.org/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
