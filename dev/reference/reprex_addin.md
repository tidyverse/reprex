# Render a reprex, conveniently

`reprex_addin()` opens an [RStudio
gadget](https://shiny.rstudio.com/articles/gadgets.html) and
[addin](https://rstudio.github.io/rstudioaddins/) that allows you to say
where the reprex source is (clipboard? current selection? active file?
other file?) and to control a few other arguments. Appears as "Render
reprex" in the RStudio Addins menu.

`reprex_selection()` is an
[addin](https://docs.posit.co/ide/user/ide/guide/productivity/add-ins.html)
that reprexes the current selection, optionally customised by options.
Appears as "Reprex selection" in the RStudio Addins menu. Heavy users
might want to [create a keyboard
shortcut](https://docs.posit.co/ide/user/ide/guide/productivity/custom-shortcuts.html).
Suggested shortcut: Cmd + Shift + R (macOS) or Ctrl + Shift + R
(Windows).

## Usage

``` r
reprex_addin()

reprex_selection(venue = getOption("reprex.venue", "gh"))
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
