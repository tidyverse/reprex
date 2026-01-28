# Changelog

## reprex (development version)

## reprex 2.1.1

CRAN release: 2024-07-06

- `reprex(style = FALSE)` will never nag about installing styler
  ([\#461](https://github.com/tidyverse/reprex/issues/461)).

- Various URLs have been updated
  ([\#458](https://github.com/tidyverse/reprex/issues/458),
  [@olivroy](https://github.com/olivroy)).

## reprex 2.1.0

CRAN release: 2024-01-11

- [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) no
  longer includes the full traceback by default, as this is only useful
  in relatively rare situations, and otherwise adds a bunch of clutter
  ([\#448](https://github.com/tidyverse/reprex/issues/448)).

- The unexported `prex_*()` functions protect the current session from
  option changes coming from reprex’s own machinery, such as disabling
  color ([\#427](https://github.com/tidyverse/reprex/issues/427)).

## reprex 2.0.2

CRAN release: 2022-08-17

- The ad placed by `reprex(advertise = TRUE)` has been tweaked for
  `venue = "gh"` (and, therefore, for its aliases `"so"` and `"ds"`) and
  `venue = "slack"`
  ([\#395](https://github.com/tidyverse/reprex/issues/395)).

- reprex takes advantage of rlang 1.0.0’s improved [support for
  backtraces in knitted
  documents](https://rlang.r-lib.org/reference/rlang_backtrace_on_error.html#errors-in-rmarkdown)
  and sets the option `rlang_backtrace_on_error_report = "full"`
  ([\#377](https://github.com/tidyverse/reprex/issues/377)).

- [`reprex_rtf()`](https://reprex.tidyverse.org/dev/reference/reprex_venue.md)
  (a shortcut for `reprex(venue = "rtf")`) now works on Windows, even if
  one of the (possibly temporary) filepaths contains a space,
  e.g. because the username contains a space
  ([\#409](https://github.com/tidyverse/reprex/issues/409),
  [@cderv](https://github.com/cderv)).

- The RStudio addin no longer displays a warning about condition length
  when selecting ‘current file’ as the reprex source
  ([\#391](https://github.com/tidyverse/reprex/issues/391),
  [@bisaloo](https://github.com/bisaloo)).

- Internal matters:

  - Help files below `man/` have been re-generated, so that they give
    rise to valid HTML5. (This is the impetus for this release, to keep
    the package safely on CRAN.)
  - reprex’s condition signalling has been updated to use the current
    approaches provided by the cli, rlang, and lifecycle packages.

## reprex 2.0.1

CRAN release: 2021-08-05

[`reprex_document()`](https://reprex.tidyverse.org/dev/reference/reprex_document.md)
has been adjusted for compatibility with changes introduced in Pandoc
2.13 around YAML headers
([\#375](https://github.com/tidyverse/reprex/issues/375),
[\#383](https://github.com/tidyverse/reprex/issues/383)
[@cderv](https://github.com/cderv)).

[`reprex_rtf()`](https://reprex.tidyverse.org/dev/reference/reprex_venue.md)
(and the unexported `prex_rtf()`) work again. One of the filepaths
involved in the highlight call was broken, but now it’s not
([\#379](https://github.com/tidyverse/reprex/issues/379)).

The unexported `prex_*()` functions once again write their files to a
temporary directory, as opposed to current working directory
([\#380](https://github.com/tidyverse/reprex/issues/380)).

## reprex 2.0.0

CRAN release: 2021-04-02

### When the clipboard isn’t available

We’ve made reprex more pleasant to use in settings where we cannot
access the user’s clipboard from R. Specifically, this applies to use on
RStudio Server and RStudio Cloud.

- When
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) is
  called without `expr` or `input`, in a context where the user’s
  clipboard can’t be reached from R, the default is now to consult the
  current selection for reprex source. Previously this was only
  available via the
  [`reprex_selection()`](https://reprex.tidyverse.org/dev/reference/reprex_addin.md)
  addin. Note that this “current selection” default behaviour propagates
  to convenience wrappers around
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md),
  such as
  [`reprex_locale()`](https://reprex.tidyverse.org/dev/reference/reprex_locale.md)
  and venue-specific functions like
  [`reprex_r()`](https://reprex.tidyverse.org/dev/reference/reprex_venue.md),
  and to the
  un-[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  functions, such as
  [`reprex_clean()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md).
- In this context, the file containing the (un)rendered reprex is opened
  so the user can manually copy its contents.

### Filepaths

`wd` is a new argument to set the reprex working directory. As a result,
the `outfile` argument is deprecated and the `input` argument has new
significance. Here’s how to use `input` and `wd` to control reprex
filepaths:

- To reprex in the current working directory,  
  Previously: `reprex(outfile = NA)`  
  Now: `reprex(wd = ".")`  
  More generally, usage looks like `reprex(wd = "path/to/desired/wd")`.
- If you really care about reprex filename (and location), write your
  source to `path/to/stuff.R` and call
  `reprex(input = "path/to/stuff.R")`. When `input` is a filepath, that
  filepath determines the working directory and how reprex files are
  named and `wd` is never even consulted.

Various changes mean that more users will see reprex filepaths.
Therefore, we’ve revised them to be more self-explanatory and
human-friendly. When reprex needs to invent a file name, it is now based
on a random “adjective-animal” slug. Bring on the `angry-hamster`!

### `.Rprofile`

[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
renders the reprex in a separate, fresh R session using
[`callr::r()`](https://callr.r-lib.org/reference/r.html). As of callr
3.4.0 (released 2019-12-09), the default became
`callr::r(..., user_profile = "project")`, which means that callr
executes a `.Rprofile` found in current working directory. Most reprexes
happen in a temp directory and there will be no such `.Rprofile`. But if
the user intentionally reprexes in an existing project with a
`.Rprofile`, [`callr::r()`](https://callr.r-lib.org/reference/r.html)
and therefore
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) honor
it. In this version of reprex:

- We explicitly make sure that the working directory of the
  [`callr::r()`](https://callr.r-lib.org/reference/r.html) call is the
  same as the effective working directory of the reprex.
- We alert the user that a local `.Rprofile` has been found.
- We indicate the usage of a local `.Rprofile` in the rendered reprex.

These changes are of special interest to users of the [renv
package](https://rstudio.github.io/renv/), which uses `.Rprofile` to
implement a project-specific R package library. Combined with the
filepath changes (described above), this means an renv user can call
`reprex(wd = ".")`, to render a reprex with respect to a
project-specific library.

### Other

HTML preview should work better with more ways of using
[`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md),
i.e. usage that doesn’t come via a call to
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
([\#293](https://github.com/tidyverse/reprex/issues/293)).

### Dependency changes

- rstudioapi moves from Suggests to Imports. Related to improving the
  experience when reprex cannot access the user’s clipboard.

- mockr is new in Suggests; it’s used in the tests.

- We bumped the documented minimum version of Pandoc, because we use the
  `gfm` markdown variant to get GitHub-Flavored Markdown. The `gfm`
  variant was introduced in Pandoc 2.0 (released 2017-10-29).

## reprex 1.0.0

CRAN release: 2021-01-27

### Venues

- `reprex_VENUE(...)` is a new way to call
  `reprex(..., venue = "VENUE")`. For example,
  [`reprex_r()`](https://reprex.tidyverse.org/dev/reference/reprex_venue.md)
  is equivalent to `reprex(venue = "r")`. This makes non-default venues
  easier to access via auto-completion
  ([\#256](https://github.com/tidyverse/reprex/issues/256)).

- `"slack"` is a new venue that tweaks the default Markdown output for
  pasting into Slack messages. It removes the `r` language identifier
  from the opening code fence, simplifies image links and, by default,
  suppresses the ad. Note that `venue = "slack"` or
  [`reprex_slack()`](https://reprex.tidyverse.org/dev/reference/reprex_venue.md)
  work best for people who opt-out of the WYSIWYG message editor: in
  *Preferences \> Advanced*, select “Format messages with markup”.

- `venue = "so"` (SO = Stack Overflow) has converged with default
  `venue = "gh"` (GitHub). As of January 2019, SO [supports CommonMark
  fenced code
  blocks](https://meta.stackexchange.com/questions/125148/implement-style-fenced-markdown-code-blocks/322000#322000).
  The only remaining difference is that Stack Overflow does not support
  the collapsible details tag that we use on GitHub to reduce the
  clutter from, e.g., session info
  ([\#231](https://github.com/tidyverse/reprex/issues/231)).

- `"rtf"` (Rich Text Format) is a new experimental `venue` for pasting
  into applications like PowerPoint and Keynote. It is experimental
  because it requires a working installation of the highlight command
  line tool, which is left as a somewhat fiddly exercise for the user
  ([\#331](https://github.com/tidyverse/reprex/issues/331)).
  `venue = "rtf"` is documented in its [own
  article](https://reprex.tidyverse.org/articles/articles/rtf.html).

- `reprex.current_venue` is a new read-only option that is set during
  [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).
  Other packages can use it to generate
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)-compatible,
  `venue`-aware output, such as an renv lockfile.

### Implementation and internals

- [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) has
  been internally refactored to make better use of the official
  machinery for extending rmarkdown:

  - [`reprex_document()`](https://reprex.tidyverse.org/dev/reference/reprex_document.md)
    is a new R Markdown output format.
  - [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md)
    is a newly exported function.
  - A
    [`reprex_document()`](https://reprex.tidyverse.org/dev/reference/reprex_document.md)
    is designed to be rendered with
    [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).
    [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md)
    is designed to act on a
    [`reprex_document()`](https://reprex.tidyverse.org/dev/reference/reprex_document.md).
    This is (still) the heart of what the
    [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
    function does, in addition to various interface and workflow
    niceties.
  - Two R Markdown templates ship with the package, which an RStudio
    user can access via *File \> New File \> R Markdown … \> From
    Template*. One is minimal; the other uses lots of reprex features.
    Both include `knit: reprex::reprex_render` in the YAML, which causes
    the RStudio “Knit” button to use
    [`reprex_render()`](https://reprex.tidyverse.org/dev/reference/reprex_render.md).

- `prex()`, `prex_VENUE()`, and `prex_render()` are new **unexported**
  functions that, like
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md),
  render a small bit of code, but with much less **re**producibility!
  The code is evaluated in the global workspace of the current process,
  with the current working directory. This pragmatic hack is useful when
  preparing a series of related snippets, e.g., for a Keynote or
  PowerPoint presentation, and there’s not enough space to make each one
  self-contained.

- UTF-8 encoding: Following the lead of knitr, reprex makes explicit use
  of UTF-8 internally
  ([\#237](https://github.com/tidyverse/reprex/issues/237)
  [@krlmlr](https://github.com/krlmlr),
  [\#261](https://github.com/tidyverse/reprex/issues/261)).

- When the reprex causes R to crash, `reprex(std_out_err = TRUE)` is
  able to provide more information about the crash, in some cases
  ([\#312](https://github.com/tidyverse/reprex/issues/312)).

### Other changes and improvements

- The `tidyverse_quiet` argument and `reprex.tidyverse_quiet` option
  also control startup messages from the
  [tidymodels](https://www.tidymodels.org) meta-package
  ([\#326](https://github.com/tidyverse/reprex/issues/326),
  [@juliasilge](https://github.com/juliasilge)).

- [`reprex_locale()`](https://reprex.tidyverse.org/dev/reference/reprex_locale.md)
  is a new thin wrapper around
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  that renders in a temporarily-altered locale
  ([\#250](https://github.com/tidyverse/reprex/issues/250)).

- The `si` argument of
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) is
  now `session_info`. Being explicit seems more important than saving
  characters, given auto-completion.

- The `show` argument of
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) is
  now `html_preview`, for the sake of consistency with other R Markdown
  output formats.

- New article on techniques for making package startup quieter
  ([\#187](https://github.com/tidyverse/reprex/issues/187),
  [@marionlouveaux](https://github.com/marionlouveaux)).

### Dependency changes

R 3.1 and R 3.2 are no longer explicitly supported or tested. Our
general practice is to support the current release (4.0, at time of
writing), devel, and the 4 previous versions of R (3.6, 3.5, 3.4, 3.3).

- sessioninfo is new in Suggests, replacing devtools.

- glue is new in Imports, replacing whisker.

- knitr moves from Suggests to Imports (although it was already a hard
  dependency via rmarkdown), so we can require v1.23 or higher, which
  represents a major switch to UTF-8.

- cli is new in Imports.

- reprex now relies on testthat \>= 3.0.0 and, specifically, uses third
  edition features.

## reprex 0.3.0

CRAN release: 2019-05-16

- The `crayon.enabled` option is explicitly set to `FALSE` when
  rendering the reprex
  ([\#238](https://github.com/tidyverse/reprex/issues/238),
  [\#239](https://github.com/tidyverse/reprex/issues/239)).

- Expression input is once again captured via
  [`substitute()`](https://rdrr.io/r/base/substitute.html) (as opposed
  to
  [`rlang::enexpr()`](https://rlang.r-lib.org/reference/defusing-advanced.html)),
  which is more favorable for reprexes involving tidy eval
  ([\#241](https://github.com/tidyverse/reprex/issues/241)).

- New venue “html” to render HTML fragments, useful for pasting in sites
  without markdown but that allow HTML
  ([\#236](https://github.com/tidyverse/reprex/issues/236)
  [@cwickham](https://github.com/cwickham)).

- The YAML of reprex’s template has been updated in light of the
  stricter YAML parser used in Pandoc \>= 2.2.2.

- [`rlang::set_attrs()`](https://rlang.r-lib.org/reference/set_attrs.html)
  has been soft-deprecated and is no longer used internally.

## reprex 0.2.1

CRAN release: 2018-09-16

- The reprex ad is formatted as superscript for `venue = "gh"` and
  `venue = "so"`, i.e. it is more subtle
  ([\#201](https://github.com/tidyverse/reprex/issues/201)).

- New experimental venue “rtf” produces syntax highlighted snippets
  suitable for pasting into presentation software such as Keynote or
  PowerPoint. This venue is discussed in [an
  article](https://reprex.tidyverse.org/articles/articles/rtf.html)
  ([\#26](https://github.com/tidyverse/reprex/issues/26)).

- Arguments `opts_chunk` and `opts_knit` have been removed from
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md).
  The same effect has always been achievable via roxygen comments in the
  reprex code and the examples have always demonstrated this. Overriding
  knitr options doesn’t seem to come up often enough in real-world
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  usage to justify these arguments.

- Internal file system operations use the [fs](https://fs.r-lib.org)
  package. This should not make any user-facing changes in reprex and we
  definitely want to know if it does.

## reprex 0.2.0

CRAN release: 2018-06-22

reprex has a website: <https://reprex.tidyverse.org>. It includes a
contributed article from [@njtierney](https://github.com/njtierney)
([\#103](https://github.com/tidyverse/reprex/issues/103)).

reprex has moved to the [tidyverse
Organization](https://github.com/tidyverse). It is installed as part of
the [tidyverse meta-package](https://www.tidyverse.org) and is
[suggested to those seeking help](https://www.tidyverse.org/help/).

[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) gains
several arguments and many arguments can now be controlled via an
option, in case a user wants their own defaults.

The new
[`reprex_selection()`](https://reprex.tidyverse.org/dev/reference/reprex_addin.md)
add-in reprexes the current selection, with venue controlled by the
option `reprex.venue`. It can be handy to bind to a keyboard shortcut
([\#84](https://github.com/tidyverse/reprex/issues/84)
[@hadley](https://github.com/hadley)).

If reprex can’t write to the user’s clipboard (e.g. on RStudio server or
Unix-like systems lacking xclip or xsel), it offers to open the output
file for manual copy.

### Option-controlled arguments for custom defaults

These look like `reprex(..., arg = opt(DEFAULT), ...)` in the help file.
This is shorthand for `arg = getOption("reprex.arg", DEFAULT)`, i.e. the
option `reprex.arg` is consulted and, if unset, the documented default
is used. Allows user to define their own default behaviour
([\#116](https://github.com/tidyverse/reprex/issues/116)).

### New arguments to `reprex()`:

- `advertise`: toggles inclusion of a footer that describes when and how
  the reprex was created, e.g., “Created on 2017-11-16 by the reprex
  package (v0.1.1.9000)”. Defaults to `TRUE`
  ([\#121](https://github.com/tidyverse/reprex/issues/121),
  [\#69](https://github.com/tidyverse/reprex/issues/69)).
- `style`: requests code restyling via the newly-Suggested styler
  package. styler can cope with tidyeval syntactical sugar,
  e.g. `df %>% group_by(!! group_var)`. Defaults to `FALSE`
  ([\#108](https://github.com/tidyverse/reprex/issues/108),
  [\#94](https://github.com/tidyverse/reprex/issues/94)).
- `tidyverse_quiet`: affords control of the startup message of the
  tidyverse meta-package. Defaults to `TRUE`, i.e. suppresses the
  message (important special case of
  [\#70](https://github.com/tidyverse/reprex/issues/70),
  [\#100](https://github.com/tidyverse/reprex/issues/100)).
- `std_out_err`: appends output sent to stdout and stderr by the reprex
  rendering process. This can be necessary to reveal output if the
  reprex spawns child processes or has
  [`system()`](https://rdrr.io/r/base/system.html) calls. Defaults to
  `FALSE` ([\#90](https://github.com/tidyverse/reprex/issues/90),
  [\#110](https://github.com/tidyverse/reprex/issues/110)).
- `render`: determines if the reprex is actually rendered or just
  returns after producing the templated `.R` file. For internal testing.

### Venues

- Line wrapping is preserved from source via a Pandoc option
  ([\#145](https://github.com/tidyverse/reprex/issues/145)
  [@jimhester](https://github.com/jimhester),
  [\#175](https://github.com/tidyverse/reprex/issues/175)).

- `venue = "gh"` now targets CommonMark as the standard for GitHub
  Flavored Markdown
  ([\#77](https://github.com/tidyverse/reprex/issues/77)).

- `venue = "so"` has appropriate whitespace at the start.

- `venue = "ds"` is a new value, corresponding to
  <https://www.discourse.org>, which is the platform behind
  [community.rstudio.com](https://forum.posit.co/). This is currently
  just an alias for the default `"gh"` GitHub venue, because the
  formatting appears to be compatible. Adding the `"ds"` value so
  Discourse can be documented and to guard against the possibility that
  some formatting is actually unique.

### Other changes

- The `keep.source` option is set to `TRUE` when rendering the reprex,
  so reprexes involving srcrefs should work
  ([\#152](https://github.com/tidyverse/reprex/issues/152)).

- The “undo” functions
  ([`reprex_invert()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md),
  [`reprex_clean()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md),
  [`reprex_rescue()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md))
  handle `input` and `outfile` like
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  does. The `outfile` argument is new
  ([\#129](https://github.com/tidyverse/reprex/issues/129),
  [\#68](https://github.com/tidyverse/reprex/issues/68)).

- The default value for knitr’s `upload.fun` is now set according to the
  venue. It is
  [`knitr::imgur_upload()`](https://rdrr.io/pkg/knitr/man/imgur_upload.html)
  for all venues except `"r"`, where it is `identity`
  ([\#125](https://github.com/tidyverse/reprex/issues/125)).

- The HTML preview should appear in the RStudio Viewer more
  consistently, especially on Windows
  ([\#75](https://github.com/tidyverse/reprex/issues/75)
  [@yutannihilation](https://github.com/yutannihilation)).

- More rigorous use of UTF-8 encoding
  ([\#76](https://github.com/tidyverse/reprex/issues/76)
  [@yutannihilation](https://github.com/yutannihilation)).

- Expression input handling has been refactored. As a result, formatR is
  no longer Suggested. Trailing comments – inline and on their own line
  – are also now retained
  ([\#89](https://github.com/tidyverse/reprex/issues/89),
  [\#91](https://github.com/tidyverse/reprex/issues/91),
  [\#114](https://github.com/tidyverse/reprex/issues/114),
  [@jennybc](https://github.com/jennybc) and
  [@jimhester](https://github.com/jimhester)).

- Custom prompts are now escaped when used in regexes
  ([\#98](https://github.com/tidyverse/reprex/issues/98),
  [\#99](https://github.com/tidyverse/reprex/issues/99)
  [@jimhester](https://github.com/jimhester)). Embedded newlines are now
  escaped.

## reprex 0.1.2

CRAN release: 2018-01-26

This was a non-functioning release created by CRAN maintainers by
commenting out lines of code relating to the clipboard.

## reprex 0.1.1

CRAN release: 2017-01-12

- Pandoc added to SystemRequirements.

## reprex 0.1.0

CRAN release: 2017-01-10

- `outfile = NA` causes outfiles to be left in working directory.
  Filenames will be based on the `input` file, if there was one.

- [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  strips any leading prompts from input code.

- Added functions
  [`reprex_clean()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md),
  [`reprex_invert()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md),
  and
  [`reprex_rescue()`](https://reprex.tidyverse.org/dev/reference/un-reprex.md)
  in order to go backwards, i.e. recover source from a wild-caught
  reprex.

- `venue = "R"` (or `"r"`) can be used to get an R script back,
  augmented with commented output.

- `comment` argument added to specify prefix for commented output.

- Added an RStudio addin, accessed via “Render reprex”.

- `input` argument to
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) and
  friends handles code as string, character vector, or file path.

- The reprex is rendered via
  [`callr::r_safe()`](https://callr.r-lib.org/reference/r.html) and is
  thus run in a clean, separate R process, eliminating any leakage of
  objects or loaded packages to/from the calling session.

- [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  gains optional arguments `opts_chunk` and `opts_knit`, taking named
  list as input, in order to supplement or override default knitr chunk
  and package options, respectively.
  ([\#33](https://github.com/tidyverse/reprex/issues/33))

  - This made the explicit `upload.fun` argument unnecessary, so it’s
    gone. The `upload.fun` option defaults to
    [`knitr::imgur_upload`](https://rdrr.io/pkg/knitr/man/imgur_upload.html),
    which means figures produced by the reprex will be uploaded to
    [imgur.com](https://imgur.com/) and the associated image syntax will
    be put into the Markdown,
    e.g. `![](https://i.imgur.com/QPU5Cg9.png)`.
    ([\#15](https://github.com/tidyverse/reprex/issues/15)
    [@paternogbc](https://github.com/paternogbc))

- Order of
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  arguments has changed.

- [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  gains the `si` argument to request that `devtools::session_info()` or
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) be
  appended to reprex code
  ([\#6](https://github.com/tidyverse/reprex/issues/6)
  [@dgrtwo](https://github.com/dgrtwo)). When `si = TRUE` and
  `venue = "gh"` (the default), session info is wrapped in a collapsible
  details tag. See [an
  example](https://github.com/tidyverse/reprex/issues/55)
  ([\#55](https://github.com/tidyverse/reprex/issues/55)).

- Reprex code can be provided as an R expression.
  ([\#6](https://github.com/tidyverse/reprex/issues/6)
  [@dgrtwo](https://github.com/dgrtwo),
  [\#35](https://github.com/tidyverse/reprex/issues/35))

- [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  uses clipboard functionality from
  [`clipr`](https://CRAN.R-project.org/package=clipr) and thus should
  work on Windows and suitably prepared Unix-like systems, in addition
  to Mac OS. ([\#16](https://github.com/tidyverse/reprex/issues/16)
  [@mdlincoln](https://github.com/mdlincoln))

## reprex 0.0.0.9000

- I tweeted about this and some people actually used it!
