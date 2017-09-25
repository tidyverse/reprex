## input is quote()'ed expression
## reprex() takes care of that or, to use directly:
## q <- quote({a + b})

#' @importFrom utils head tail getSrcref
stringify_expression <- function(x) {

  # Construct a new sourcref with the starts from the first expression and the
  # ends from the last one.
  first_src <- head(getSrcref(x), n = 1)[[1]]
  last_src <- tail(getSrcref(x), n = 1)[[1]]

  if (is.null(first_src)) {
    return(deparse(x))
  }
  src <- srcref(attr(first_src, "srcfile"),
    c(first_src[[1]], first_src[[2]],
      last_src[[3]], last_src[[4]],
      first_src[[5]], last_src[[6]],
      first_src[[7]], last_src[[8]]))

  lines <- as.character(src, useSource = TRUE)

  # remove the first brace and line if the brace is the only thing on the line
  lines <- sub("^[{]", "", lines)
  if (!nzchar(lines[[1L]])) {
    lines <- lines[-1L]
  }

  lines
}
