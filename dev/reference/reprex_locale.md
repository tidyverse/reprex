# Render a reprex in a specific locale

Render a
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md), with
control over the localization of error messages and aspects of the
locale. Note that these are related but distinct issues! Typical usage
is for someone on a Spanish system to create a reprex that is easier for
an English-speaking audience to follow.

## Usage

``` r
reprex_locale(..., language = "en", locale = NULL)
```

## Arguments

- ...:

  Inputs passed through to
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md).

- language:

  A string specifying the preferred language for messages. It is enacted
  via the `LANGUAGE` environment variable, for the duration of the
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  call. Examples: `"en"` for English and `"fr"` for French. See Details
  for more.

- locale:

  A named character vector, specifying aspects of the locale, in the
  [`Sys.setlocale()`](https://rdrr.io/r/base/locales.html) sense. It is
  enacted by setting one or more environment variables, for the duration
  of the
  [`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
  call. See Details for more.

## Value

Character vector of rendered reprex, invisibly.

## `language`

Use the `language` argument to express the preferred language of error
messages. The output of `dir(system.file(package = "translations"))` may
provide some helpful ideas. The `language` should generally follow "XPG
syntax": a two-letter language code, optionally followed by other
modifiers.

Examples: `"en"`, `"de"`, `"en_GB"`, `"pt_BR"`.

## `locale`

Use the `locale` argument only if you want to affect something like how
day-of-the-week or month is converted to character. You are less likely
to need to set this than the `language` argument. You may have more
success setting specific categories, such as `"LC_TIME"`, than
multi-category shortcuts like `"LC_ALL"` or `"LANG"`. The `locale`
values must follow the format dictated by your operating system and the
requested locale must be installed. On \*nix systems, `locale -a` is a
good way to see which locales are installed. Note that the format for
`locale` and `language` are different from each other on Windows.

Examples: `"en_CA.UTF-8"` (macOS), `"French_France.1252"` (Windows).

## See also

- The [Locale
  Names](https://www.gnu.org/software/libc/manual/html_node/Locale-Names.html)
  section of the GNU C docs, for more about XPG syntax

- The [Internationalization and
  Localization](https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#Internationalization)
  section of the R Installation and Administration manual

## Examples

``` r
if (FALSE) { # \dontrun{

# if all you want to do is make sure messages are in English
reprex_locale("a" / 2)

# change messages to a specific language
reprex_locale(
  {
    "a" / 2
  },
  language = "it"
)

reprex_locale(
  {
    "a" / 2
  },
  language = "fr_CA"
)

reprex_locale(
  {
    "a" / 2
  },
  language = "pt_BR"
)

# get day-of-week and month to print in French (not Windows)
reprex_locale(
  {
    format(as.Date(c("2019-01-01", "2019-02-01")), "%a %b %d")
  },
  locale = c(LC_TIME = "fr_FR")
)

# get day-of-week and month to print in French (Windows)
# assumes that the relevant language is installed on the system
# LC_TIME can also be specified as "French" or "French_France" here
reprex_locale(
  {
    format(as.Date(c("2019-01-01", "2019-02-01")), "%a %b %d")
  },
  locale = c(LC_TIME = "French_France.1252")
)
} # }
```
