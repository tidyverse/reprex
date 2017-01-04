
-   [reprex](#reprex)
-   [Install and load](#install-and-load)
-   [Quick start](#quick-start)

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/jennybc/reprex.svg?branch=master)](https://travis-ci.org/jennybc/reprex) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jennybc/reprex?branch=master&svg=true)](https://ci.appveyor.com/project/jennybc/reprex) [![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip) [![](https://www.r-pkg.org/badges/version/reprex)](https://www.r-pkg.org/pkg/reprex) [![Coverage Status](https://img.shields.io/codecov/c/github/jennybc/reprex/master.svg)](https://codecov.io/github/jennybc/reprex?branch=master)

reprex
------

<a href="https://nypdecider.files.wordpress.com/2014/08/help-me-help-you.gif"> <img src="https://raw.githubusercontent.com/jennybc/reprex/master/img/help-me-help-you-still-500-c256.png" width="275" align="right"> </a>

Prepare reproducible examples for posting to [GitHub issues](https://guides.github.com/features/issues/), [StackOverflow](http://stackoverflow.com/questions/tagged/r), etc.

Given R code on the clipboard, as an expression (quoted or not), or in a file ...

-   run it via `rmarkdown::render()`,
-   with deliberate choices re: arguments and setup chunk.

Get resulting runnable code + output as

-   Markdown, formatted for target venue, e.g. `gh` or `so`, or as
-   R code, augmented with commented output.

Result is returned invisibly, placed on the clipboard and written to file.

Preview an HTML version in RStudio viewer or default browser.

Install and load
----------------

``` r
devtools::install_github("jennybc/reprex")
library(reprex)
```

Quick start
-----------

Let's say you copy this code onto your clipboard:

    (y <- 1:4)
    mean(y)

Then call `reprex()`, where the default target venue is GitHub:

``` r
reprex()
```

A nicely rendered HTML preview will display in RStudio's Viewer (if you're in RStudio) or your default browser otherwise.

![html-preview](https://raw.githubusercontent.com/jennybc/reprex/master/img/README-viewer-screenshot.png)

The relevant bit of GitHub-flavored Markdown is ready to be pasted from your clipboard:

    ``` r
    (y <- 1:4)
    #> [1] 1 2 3 4
    mean(y)
    #> [1] 2.5
    ```

Here's what that Markdown would look like rendered in a GitHub issue:

``` r
(y <- 1:4)
#> [1] 1 2 3 4
mean(y)
#> [1] 2.5
```

Anyone else can copy, paste, and run this immediately.

But wait, there's more!

-   Set the target venue to StackOverflow with `reprex(..., venue = "so")`.
-   Get a runnable R script, augmented with commented output, with `reprex(..., venue = "R")`.
-   By default, figures are uploaded to [imgur.com](http://imgur.com) and resulting URL is dropped into an inline image tag.
-   Alternatives to clipboard input:
    -   `reprex({(y <- 1:4); mean(y)})` gets code from expression

``` r
knitr::knit_exit()
```
