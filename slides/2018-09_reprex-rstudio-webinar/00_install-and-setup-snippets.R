#+ eval = FALSE
## install JUST reprex
install.packages("reprex")

## install reprex, as part of the tidyverse
install.packages("tidyverse")

#+ eval = FALSE
## before you can use reprex(), do this:
library(reprex)

#+ eval = FALSE
## put this in ~/.Rprofile to make reprex
## available 24/7
if (interactive()) {
  suppressMessages(require(reprex))
}

## one way to create or open your .Rprofile
## install.packages("usethis")
usethis::edit_r_profile()

#+ eval = FALSE
reprex()
