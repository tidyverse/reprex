# reprex options

Some [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
behaviour can be controlled via an option, providing a way for the user
to set personal defaults. The pattern for such option names is
`reprex.<arg>`, where `<arg>` is an argument of
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md). Here
are the main ones:

- `reprex.advertise`

- `reprex.session_info` (previously, `reprex.si`)

- `reprex.style`

- `reprex.html_preview` (previously, `reprex.show`)

- `reprex.comment`

- `reprex.tidyverse_quiet`

- `reprex.std_out_err`

A few more options exist, but are only relevant to specific situations:

- `reprex.venue`: Can be used to control the `venue` used by the
  [`reprex_selection()`](https://reprex.tidyverse.org/dev/reference/reprex_addin.md)
  addin.

- `reprex.current_venue`: Read-only option that is set during
  [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).
  Other packages that want to generate reprex-compatible output can
  consult it via `getOption("reprex.current_venue")`, if they want to
  tailor their output to the `venue`.

- `reprex.clipboard`: When `FALSE`, reprex makes no attempt to access
  the user's clipboard, ever. This exists mostly for internal use, i.e.
  we set it to `FALSE` when we detect use from RStudio Server. But a
  user could set this to `FALSE` to explicitly opt-out of clipboard
  functionality. A Linux user with no intention of installing `xclip` or
  `xsel` might also do this.

- `reprex.highlight.hl_style`: Only relevant to `venue = "rtf`. Details
  are in the article [reprex venue
  RTF](https://reprex.tidyverse.org/articles/articles/rtf.html).

- `reprex.highlight.font`: See above.

- `reprex.highlight.font_size`: See above.

- `reprex.highlight.other`: See above.

Here's code you could put in `.Rprofile` to set reprex options. It would
be rare to want non-default behaviour for all of these! We only do so
here for the sake of exposition:

    options(
      reprex.advertise       = FALSE,
      reprex.session_info    = TRUE,
      reprex.style           = TRUE,
      reprex.html_preview    = FALSE,
      reprex.comment         = "#;-)",
      reprex.tidyverse_quiet = FALSE,
      reprex.std_out_err     = TRUE,
      reprex.venue           = "html", # NOTE: only affects reprex_selection()!
      reprex.highlight.hl_style  = "acid", # NOTE: only affects RTF venue
      reprex.highlight.font      = "Andale Mono Regular",
      reprex.highlight.font_size = 35,
      reprex.highlight.other     = "--line-numbers"
    )

The function `usethis::edit_r_profile()` is handy for creating and/or
opening your `.Rprofile`.

## Explaining the `opt()` helper

Arguments that appear like so in
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md):

    reprex(..., arg = opt(DEFAULT), ...)

get their value according to this logic:

    user-specified value or, if not given,
      getOption("reprex.arg") or, if does not exist,
        DEFAULT

It's shorthand for:

    f(..., arg = getOption("reprex.arg", DEFAULT), ...)

This is not an exported function and should not be called directly.
