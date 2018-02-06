# reprex 0.2.0

reprex has a website: <http://reprex.tidyverse.org>. It includes a contributed article from @njtierney (#103).

reprex has moved to the [tidyverse Organization](https://github.com/tidyverse). It is installed as part of the [tidyverse meta-package](https://www.tidyverse.org) and is [suggested to those seeking help](https://www.tidyverse.org/help/). 

`reprex()` gains several arguments and many arguments can now be controlled via an option, in case a user wants their own defaults.

The new `reprex_selection()` add-in reprexes the current selection, with venue controlled by the option `reprex.venue`. It can be handy to bind to a keyboard shortcut (#84 @hadley).

If reprex can't write to the user's clipboard (e.g. on RStudio server or Unix-like systems lacking xclip or xsel), it offers to open the output file for manual copy.

## Option-controlled arguments for custom defaults

These look like `reprex(..., arg = opt(DEFAULT), ...)` in the help file. This is shorthand for `arg = getOption("reprex.arg", DEFAULT)`, i.e. the option `reprex.arg` is consulted and, if unset, the documented default is used. Allows user to define their own default behaviour (#116).

## New arguments to `reprex()`:

  * `advertise`: toggles inclusion of a footer that describes when and how the reprex was created, e.g., "Created on 2017-11-16 by the reprex package (v0.1.1.9000)". Defaults to `TRUE` (#121, #69).
  * `style`: requests code restyling via the newly-Suggested styler package. styler can cope with tidyeval syntactical sugar, e.g. `df %>% group_by(!! group_var)`. Defaults to `FALSE` (#108, #94).
  * `tidyverse_quiet`: affords control of the startup message of the tidyverse meta-package. Defaults to `TRUE`, i.e. suppresses the message (important special case of #70, #100).
  * `std_out_err`: appends output sent to stdout and stderr by the reprex rendering process. This can be necessary to reveal output if the reprex spawns child processes or has `system()` calls. Defaults to `FALSE` (#90, #110).
  * `render`: determines if the reprex is actually rendered or just returns after producing the templated `.R` file. For internal testing.

## Venues

  * Line wrapping is preserved from source via a Pandoc option (#145 @jimhester, #175).

  * `venue = "gh"` now targets CommonMark as the standard for GitHub Flavored Markdown (#77).
  
  * `venue = "so"` has appropriate whitespace at the start.

  * `venue = "ds"` is a new value, corresponding to <https://www.discourse.org>, which is the platform behind [community.rstudio.com](https://community.rstudio.com). This is currently just an alias for the default `"gh"` GitHub venue, because the formatting appears to be compatible. Adding the `"ds"` value so Discourse can be documented and to guard against the possibility that some formatting is actually unique.
  
## Other changes

  * The `keep.source` option is set to `TRUE` when rendering the reprex, so reprexes involving srcrefs should work (#152).
  
  * The "undo" functions (`reprex_invert()`, `reprex_clean()`, `reprex_rescue()`) handle `input` and `outfile` like `reprex()` does. The `outfile` argument is new (#129, #68).

  * The default value for knitr's `upload.fun` is now set according to the venue. It is `knitr::imgur_upload()` for all venues except `"r"`, where it is `identity` (#125).

  * The HTML preview should appear in the RStudio Viewer more consistently, especially on Windows (#75 @yutannihilation).
  
  * More rigorous use of UTF-8 encoding (#76 @yutannihilation).

  * Expression input handling has been refactored. As a result, formatR is no longer Suggested. Trailing comments -- inline and on their own line -- are also now retained (#89, #91, #114, @jennybc and @jimhester).

  * Custom prompts are now escaped when used in regexes (#98, #99 @jimhester). Embedded newlines are now escaped.

# reprex 0.1.2

This was a non-functioning release created by CRAN maintainers by commenting out lines of code relating to the clipboard.

# reprex 0.1.1

  * pandoc added to SystemRequirements.

# reprex 0.1.0

  * `outfile = NA` causes outfiles to be left in working directory. Filenames will be based on the `input` file, if there was one.

  * `reprex()` strips any leading prompts from input code.

  * Added functions `reprex_clean()`, `reprex_invert()`, and `reprex_rescue()` in order to go backwards, i.e. recover source from a wild-caught reprex.

  * `venue = "R"` (or `"r"`) can be used to get an R script back, augmented with commented output.

  * `comment` argument added to specify prefix for commented output.

  * Added an RStudio addin, accessed via "Render reprex".

  * `input` argument to `reprex()` and friends handles code as string, character vector, or file path.

  * The reprex is rendered via `callr::r_safe()` and is thus run in a clean, separate R process, eliminating any leakage of objects or loaded packages to/from the calling session.

  * `reprex()` gains optional arguments `opts_chunk` and `opts_knit`, taking named list as input, in order to supplement or override default knitr chunk and package options, respectively. (#33)
    - This made the explicit `upload.fun` argument unnecessary, so it's gone. The `upload.fun` option defaults to `knitr::imgur_upload`, which means figures produced by the reprex will be uploaded to [imgur.com](http://imgur.com) and the associated image syntax will be put into the Markdown, e.g. `![](http://i.imgur.com/QPU5Cg9.png)`. (#15 @paternogbc)
    
  * Order of `reprex()` arguments has changed.

  * `reprex()` gains the `si` argument to request that `devtools::session_info()` or `sessionInfo()` be appended to reprex code (#6 @dgrtwo). When `si = TRUE` and `venue = "gh"` (the default), session info is wrapped in a collapsible details tag. See [an example](https://github.com/tidyverse/reprex/issues/55) (#55).

  * Reprex code can be provided as an R expression. (#6 @dgrtwo, #35)
  
  * `reprex()` uses clipboard functionality from [`clipr`](https://CRAN.R-project.org/package=clipr) and thus should work on Windows and suitably prepared Unix-like systems, in addition to Mac OS. (#16 @mdlincoln)

# reprex 0.0.0.9000

  * I tweeted about this and some people actually used it!
