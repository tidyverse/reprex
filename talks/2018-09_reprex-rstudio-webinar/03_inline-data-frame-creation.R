x <- read.csv(text = "a,b\n1,2\n3,4")
x

x <- data.frame(
  a = c(1, 2),
  b = c(3, 4)
)
x

library(readr)
x <- read_csv("a,b\n1,2\n3,4")
x

library(tibble)
x <- tribble(
  ~a, ~b,
   1,  2,
   3,  4
)
x

x <- tibble(
  a = c(1, 2),
  b = c(3, 4)
)
x

## what if you already have an object and you want
## the tribble() call to define it?
library(datapasta)
x <- tribble_construct(head(iris))
cat(x)

## what if you already have an object and you want
## the tribble() call to define it?
## install.packages("krlmlr/deparse")
library(deparse)
x <- deparse(head(iris), as_tribble = TRUE)
cat(x)
