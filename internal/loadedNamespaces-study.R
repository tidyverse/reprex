# it is interesting to look at this with and without styler installed

callr_pkgs <- callr::r(function() loadedNamespaces())

writeLines("loadedNamespaces()", "foo.R")
callr::r(function() {
  rmarkdown::render("foo.R", output_format = "md_document")
})
x <- unlist(stringr::str_extract_all(readLines("foo.md"), '".+?"'))
render_pkgs <- gsub('"', '', x)

sort(setdiff(render_pkgs, callr_pkgs))

out <- reprex::reprex(loadedNamespaces())
x <- unlist(stringr::str_extract_all(out, '".+?"'))
reprex_pkgs <- gsub('"', '', x)

(hmm <- sort(setdiff(reprex_pkgs, render_pkgs)))

d <- desc::desc(package = "reprex")
reprex_deps <- d$get_deps()
reprex_imports <- sort(reprex_deps$package[reprex_deps$type == "Imports"])
reprex_suggests <- sort(reprex_deps$package[reprex_deps$type == "Suggests"])
reprex_imports_and_suggests <- c(reprex_imports, reprex_suggests)

setdiff(hmm, reprex_imports)
setdiff(hmm, reprex_imports_and_suggests)
