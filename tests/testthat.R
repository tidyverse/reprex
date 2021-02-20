library(testthat)
library(reprex)

if (rmarkdown::pandoc_available("2.0.0")) {
  test_check("reprex")
}
