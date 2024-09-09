# use the CSS found here:
# https://github.com/sindresorhus/github-markdown-css
# which aims to be:
# "The minimal amount of CSS to replicate the GitHub Markdown style"

library(usethis)

use_directory("inst/rmarkdown/templates/reprex_document/resources")

use_github_file(
  repo_spec = "sindresorhus/github-markdown-css",
  path = "github-markdown-dark.css",
  save_as = "inst/rmarkdown/templates/reprex_document/resources/github-dark.css"
)

use_github_file(
  repo_spec = "sindresorhus/github-markdown-css",
  path = "github-markdown-light.css",
  save_as = "inst/rmarkdown/templates/reprex_document/resources/github-light.css"
)
