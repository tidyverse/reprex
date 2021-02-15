## code to prepare `adjective_animal` dataset goes here
library(ids)

set.seed(1031)
adjective_animal <- adjective_animal(n = 100, max_len = 5, style = "kebab")
anyDuplicated(adjective_animal)

usethis::use_data(adjective_animal, internal = TRUE, overwrite = TRUE)
