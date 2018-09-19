x <- read.csv(text = "a,b\n1,2\n3,4")
x

x <- data.frame(
  a = c(1, 2),
  b = c(3, 4)
)
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
