# write Pandoc's default (pygments) highlight style to a JSON file
# pandoc --print-highlight-style pygments > data-raw/pygments.theme
# use this as a scaffold, but modify colors to match the Starry Night theme
# that GitHub uses

library(tidyverse)

pyg <- jsonlite::fromJSON("data-raw/pygments.theme")
pyg |> pluck("text-styles") |> names()

# How does Pandoc do syntax highlighting?
# https://pandoc.org/chunkedhtml-demo/13-syntax-highlighting.html
# "The Haskell library skylighting is used for highlighting."

# Pandoc/skylighting store themes using the
# Syntax-Highlighting framework from KDE Frameworks

# Learn the meaning of the styles (classes) supported by Pandoc here:
# https://docs.kde.org/stable5/en/kate/katepart/highlight.html
#   see "Available Default Styles"
# https://docs.kde.org/stable5/en/kate/katepart/color-themes.html
#   see "Default Text Styles"

# this is me taking the styles Pandoc/skylighting expects,
# noting what they are meant for conceptually,
# and picking the starry-night color alias/variable that seems the best fit

x <- str_glue('
  Alert,"Text style for special words in comments, such as TODO, FIXME, XXXX and WARNING.",\\
  comment,
  Annotation,"Text style for annotations in comments or documentation commands, such as @param in Doxygen or JavaDoc.",\\
  comment,
  Attribute,"Text style for annotations or attributes of functions or objects, e.g. @override in Java, or __declspec(...) and __attribute__((...)) in C++.",\\
  entity-tag,
  BaseN,"(Base-N Integer): Text style for numbers with base other than 10.",\\
  constant,
  BuiltIn,"(Built-in): Text style for built-in language classes, functions and objects.",\\
  entity,
  Char,"(Character): Text style for single characters such as \'x\'.",\\
  string,
  Comment, "Text style for normal comments.",\\
  comment,
  CommentVar,"(Comment Variable): Text style that refers to variables names used in above commands in a comment, such as foobar in \'@param foobar\', in Doxygen or JavaDoc.",\\
  comment,
  Constant,"Text style for language constants and user defined constants, e.g. True, False, None in Python or nullptr in C/C++; or math constants like PI.",\\
  constant,
  ControlFlow,"(Control Flow): Text style for control flow keywords, such as if, then, else, return, switch, break, yield, continue, etc.",\\
  keyword,
  DataType,"(Data Type): Text style for built-in data types such as int, char, float, void, u64, etc.",\\
  constant,
  DecVal,"(Decimal/Value): Text style for decimal values.",\\
  constant,
  Documentation,"Text style for comments that reflect API documentation, such as /** doxygen comments */ or \"\"\"docstrings\"\"\".",\\
  comment,
  Error,"Text style indicating error highlighting and wrong syntax.",\\
  invalid-illegal-text,invalid-illegal-bg
  Extension,"Text style for well-known extensions, such as Qt™ classes, functions/macros in C++ and Python or boost.",\\
  entity,
  Float,"(Floating Point): Text style for floating point numbers.",\\
  constant,
  Function,"Text style for function definitions and function calls.",\\
  entity,
  Import,"(Imports, Modules, Includes): Text style for includes, imports, modules or LATEX packages.",\\
  storage-modifier-import,
  Information,"Text style for information, notes and tips, such as the keyword @note in Doxygen.",\\
  comment,
  Keyword,"Text style for built-in language keywords.",\\
  keyword,
  Operator,"Text style for operators, such as +, -, *, /, %, etc.",\\
  keyword,
  Others,"Text style for attributes that do not match any of the other default styles.",\\
  ,
  Preprocessor,"Text style for preprocessor statements or macro definitions.",\\
  keyword,
  SpecialChar,"(Special Character): Text style for escaped characters in strings, e.g. \"hello\\n\", and other characters with special meaning in strings, such as substitutions or regex operators.",\\
  carriage-return-text,carriage-return-bg
  SpecialString,"(Special String): Text style for special strings, such as regular expressions in ECMAScript, the LATEX math mode, SQL, etc.",\\
  string-regexp,
  String,"Text style for strings like \"hello world\".",\\
  string,
  Variable,"Text style for variables, if applicable. For instance, variables in PHP/Perl typically start with a $, so all identifiers following the pattern $foo are highlighted as variable.",\\
  variable,
  VerbatimString,"(Verbatim String): Text style for verbatim or raw strings like \'raw \backlash\' in Perl, CoffeeScript, and shells, as well as r\'\raw\' in Python, or such as HERE docs.",\\
  string,
  Warning,"Text style for warnings, such as the keyword @warning in Doxygen.",\\
  comment,
')

dat <- read_csv(x, col_names = c("pyg_class", "pyg_note", "pl_text_style", "pl_background_style"))
dat

# get the starry-night css in order to excavate the colors
use_github_file(
  repo_spec = "wooorm/starry-night",
  path = "style/dark.css",
  save_as = "data-raw/starry-night-dark.css"
)

use_github_file(
  repo_spec = "wooorm/starry-night",
  path = "style/light.css",
  save_as = "data-raw/starry-night-light.css"
)

raw_css_lines <- readLines("data-raw/starry-night-light.css")
sn_light <- raw_css_lines |>
  str_subset("  --color-prettylights-syntax-") |>
  tibble() |>
  set_names("raw") |>
  mutate(comment = str_extract(raw, ".+:")) |>
  mutate(color = str_extract(raw, "#[0-9a-fA-F]{6}")) |>
  mutate(comment = str_remove(comment, "  --color-prettylights-syntax-")) |>
  mutate(comment = str_remove(comment, ":$")) |>
  select(comment, color)

raw_css_lines <- readLines("data-raw/starry-night-dark.css")
sn_dark <- raw_css_lines |>
  str_subset("  --color-prettylights-syntax-") |>
  tibble() |>
  set_names("raw") |>
  mutate(comment = str_extract(raw, ".+:")) |>
  mutate(color = str_extract(raw, "#[0-9a-fA-F]{6}")) |>
  mutate(comment = str_remove(comment, "  --color-prettylights-syntax-")) |>
  mutate(comment = str_remove(comment, ":$")) |>
  select(comment, color)

dat
sn_light
sn_dark

dat_light <- dat |>
  rename(cls = pyg_class) |>
  select(-pyg_note) |>
  left_join(
    sn_light,
    by = join_by(pl_text_style == comment)
  ) |>
  rename(txt_col = color) |>
  left_join(
    sn_light,
    by = join_by(pl_background_style == comment)
  ) |>
  rename(bg_col = color) |>
  select(-starts_with("pl_"))
dat_light

dat_dark <- dat |>
  rename(cls = pyg_class) |>
  select(-pyg_note) |>
  left_join(
    sn_dark,
    by = join_by(pl_text_style == comment)
  ) |>
  rename(txt_col = color) |>
  left_join(
    sn_dark,
    by = join_by(pl_background_style == comment)
  ) |>
  rename(bg_col = color) |>
  select(-starts_with("pl_"))
dat_dark

g <- function(cls, txt_col, bg_col) {
  list(
    `text-color` = txt_col,
    `background-color` = bg_col,
    bold = FALSE,
    italic = FALSE,
    underline = FALSE
  )
}

theme_light <- theme_dark <- pyg
theme_light[["text-styles"]] <- dat_light |>
  pmap(g) |>
  set_names(dat_light$cls)
theme_dark[["text-styles"]] <- dat_dark |>
  pmap(g) |>
  set_names(dat_dark$cls)

jsonlite::write_json(
  theme_light,
  "inst/rmarkdown/templates/reprex_document/resources/starry-nights-light.theme",
  null = "null",
  auto_unbox = TRUE,
  pretty = TRUE
)

jsonlite::write_json(
  theme_dark,
  "inst/rmarkdown/templates/reprex_document/resources/starry-nights-dark.theme",
  null = "null",
  auto_unbox = TRUE,
  pretty = TRUE
)
