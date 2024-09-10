library(usethis)

# the true source lives in KDE's GitLab instance, but I think this GitHub mirror
# is good enough
# https://invent.kde.org/frameworks/syntax-highlighting
# https://github.com/KDE/syntax-highlighting/blob/master/data/syntax/r.xml
use_github_file(
  repo_spec = "KDE/syntax-highlighting",
  path = "data/syntax/r.xml",
  save_as = "data-raw/r.xml"
)

fs::file_copy(
  "data-raw/r.xml",
  "inst/rmarkdown/templates/reprex_document/resources/r.xml"
)

# I then made some edits in the itemDatas section
# I changed some of the default styles
