### Formatting principles

Notes and links re: best formatting for different venues.

Stack Overflow

  * <http://stackoverflow.com/editing-help>
  * specifics re: [code highlighting](http://stackoverflow.com/editing-help#syntax-highlighting)

GitHub

  * GitHub issues use [GitHub-flavored markdown](https://help.github.com/articles/github-flavored-markdown/)

gist.github.com

  - In theory, this is the domain of [`gistr`](https://github.com/ropensci/gistr), but people also tend to post `.R` or `.Rmd` and NOT resulting `.md` ... is there a gap in tools or is this just an unfortunate behavior pattern? I don't always want to render these files to see what someone's trying to show me.

### Notes to self

Lines where a `.R` file gets spun in `render()`: [render.R\#L129-L154](https://github.com/rstudio/rmarkdown/blob/88afb8d4d6f4371d67b82059baaee1052d2bc55f/R/render.R#L129-L154)

#### Other work

The "great R reproducible example" Stack Overflow thread referenced above has some discussion of practical details, such as [this comment](http://stackoverflow.com/questions/5963269/how-to-make-a-great-r-reproducible-example/16532098#16532098).

The "Code to import data from a Stack overflow query into R" [stackoverflow thread](http://stackoverflow.com/questions/10849270/code-to-import-data-from-a-stack-overflow-query-into-r/10849315). This is from the perspective of someone considering *answering* a question, in which the OP has not provided a proper reprex. Specifically: it addresses input data that is in suboptimal form.

A collection of R scripts by GitHub user rsaporta contains some functions related to Stack Overflow: [so\_functions.r](https://github.com/rsaporta/pubR/blob/fe487d7020311b19b92d80e214800813188ad793/so_functions.r). No license.

The [GitHub package `overflow`](https://github.com/sebastian-c/overflow/). Appears to also emphasize the difficulty above, e.g., getting data out of Stack Overflow questions that don't follow reprex best practices. A bit hard to tell what's there, not much in README, no vignette. License is GPL-3.
