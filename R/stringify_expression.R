## input is quote()'ed expression
## reprex() takes care of that or, to use directly:
## x <- quote({a + b})

stringify_expression <- function(x) {

  .srcref <- utils::getSrcref(x)

  if (is.null(.srcref)) {
    return(deparse(x))
  }

  ## Construct a new srcref with the first_line, first_byte, etc. from the
  ## first expression and the last_line, last_byte, etc. from the last one.
  first_src <- .srcref[[1]]
  last_src <- .srcref[[length(.srcref)]]

  .srcfile <- attr(first_src, "srcfile")

  src <- srcref(
    .srcfile,
    c(first_src[[1]], first_src[[2]],
       last_src[[3]],  last_src[[4]],
      first_src[[5]],  last_src[[6]],
      first_src[[7]],  last_src[[8]])
  )

  lines <- as.character(src, useSource = TRUE)

  ## remove the first brace and line if the brace is the only thing on the line
  lines <- sub("^[{]", "", lines)
  if (!nzchar(lines[[1L]])) {
    lines <- lines[-1L]
  }

  ## rescue trailing comment lines
  ## n = the last line affiliated with an expression
  ## FYI the 3rd element corresponds to last_line
  n <- max(vapply(.srcref, function(x) x[[3]], integer(1)))
  tail_lines <- getSrcLines(.srcfile, n + 1, Inf)
  closing_bracket_line <- max(grep("^\\s*[}]", tail_lines), 0)
  tail_lines <- utils::head(tail_lines, closing_bracket_line - 1)

  trim_common_leading_ws(c(lines, tail_lines))
}

