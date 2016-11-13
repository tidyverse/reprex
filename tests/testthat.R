library(testthat)
library(reprex)

## don't run tests on appveyor til pandoc sorted out
if (!identical(tolower(Sys.getenv("APPVEYOR")), "true")) {
  test_check("reprex")
}
