## this file and function will go away once clipr offers this
## it's just useful to have during development and in tests

cb_clear <- function() {
  system("pbcopy < /dev/null")
}
