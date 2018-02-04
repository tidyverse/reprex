library(testthat)
library(reprex)

if (rmarkdown::pandoc_available()) {
  test_check("reprex")
}
