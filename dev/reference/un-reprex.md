# Un-render a reprex

Recover clean, runnable code from a reprex captured in the wild and
write it to user's clipboard. The code is also returned invisibly and
optionally written to file. Three different functions address various
forms of wild-caught reprex:

- `reprex_invert()` attempts to reverse the effect of
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md).
  When `venue = "r"`, this just calls `reprex_clean()`.

- `reprex_clean()` removes commented output. This assumes that R code is
  top-level, possibly interleaved with commented output, e.g., a
  displayed reprex copied from GitHub or the output of
  `reprex(..., venue = "R")`.

- `reprex_rescue()` removes lines of output and strips prompts from
  lines holding R commands. This assumes that R code lines start with a
  prompt and that printed output is top-level, e.g., what you'd if
  you've copied from the R Console.

## Usage

``` r
reprex_invert(
  input = NULL,
  wd = NULL,
  venue = c("gh", "r"),
  comment = opt("#>"),
  outfile = deprecated()
)

reprex_clean(
  input = NULL,
  wd = NULL,
  comment = opt("#>"),
  outfile = deprecated()
)

reprex_rescue(
  input = NULL,
  wd = NULL,
  prompt = getOption("prompt"),
  continue = getOption("continue"),
  outfile = deprecated()
)
```

## Arguments

- input:

  Character. If has length one and lacks a terminating newline,
  interpreted as the path to a file containing the reprex. Otherwise,
  assumed to hold the reprex as a character vector. If not provided, the
  clipboard is consulted for input. If the clipboard is unavailable and
  we're in RStudio, the current selection is used.

- wd:

  An optional filepath that is consulted when `input` is not a filepath.
  (By default, all work is done, quietly, in a subdirectory of the
  session temp directory.)

  The most common use of `wd` is to set `wd = "."`, which means "reprex
  right HERE in the current working directory". Do this if you really
  must demonstrate something with local files.

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

- comment:

  regular expression that matches commented output lines

- outfile:

  **\[deprecated\]** in favor of `wd` or providing a filepath to
  `input`. To reprex in current working directory, use `wd = "."` now,
  instead of `outfile = NA`.

- prompt:

  character, the prompt at the start of R commands

- continue:

  character, the prompt for continuation lines

## Value

Character vector holding just the clean R code, invisibly

## Examples

``` r
if (FALSE) { # \dontrun{
# a roundtrip: R code --> rendered reprex, as gfm --> R code
original <- file.path(tempdir(), "original.R")
writeLines(glue::glue("
  #' Some text
  #+ chunk-label-and-options-cannot-be-recovered, message = TRUE
  (x <- 1:4)
  #' More text
  y <- 2:5
  x + y"), con = original)
reprex(input = original, html_preview = FALSE, advertise = FALSE)
reprexed <- sub("[.]R$", "_reprex.md", original)
writeLines(readLines(reprexed))
unreprexed <- reprex_invert(input = reprexed)
writeLines(unreprexed)

# clean up
file.remove(
  list.files(dirname(original), pattern = "original", full.names = TRUE)
)
} # }
if (FALSE) { # \dontrun{
# a roundtrip: R code --> rendered reprex, as R code --> original R code
code_in <- c(
  "# a regular comment, which is retained",
  "(x <- 1:4)",
  "median(x)"
)
reprexed <- reprex(input = code_in, venue = "r", advertise = FALSE)
writeLines(reprexed)
code_out <- reprex_clean(input = reprexed)
writeLines(code_out)
identical(code_in, code_out)
} # }
if (FALSE) { # \dontrun{
# rescue a reprex that was copied from a live R session
from_r_console <- c(
  "> # a regular comment, which is retained",
  "> (x <- 1:4)",
  "[1] 1 2 3 4",
  "> median(x)",
  "[1] 2.5"
)
rescued <- reprex_rescue(input = from_r_console)
writeLines(rescued)
} # }
```
