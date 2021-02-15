.onLoad <- function(libname, pkgname) {
  withr::with_preserve_seed({
    # create a new random permutation every time we load
    adjective_animal <<- sample(adjective_animal, size = length(adjective_animal))
  })
  invisible()
}
