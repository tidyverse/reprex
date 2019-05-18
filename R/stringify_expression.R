## input is quote()'ed expression
## reprex() takes care of that or, to use directly:
## x <- quote({a + b})

stringify_expression <- function(x) {
  if (is.null(x)) return(NULL)

  .srcref <- utils::getSrcref(x)

  if (is.null(.srcref)) {
    return(enc2utf8(deparse(x)))
  }

  ## Construct a new srcref with the first_line, first_byte, etc. from the
  ## first expression and the last_line, last_byte, etc. from the last one.
  first_src <- .srcref[[1]]
  last_src <- .srcref[[length(.srcref)]]

  .srcfile <- attr(first_src, "srcfile")

  src <- srcref(
    .srcfile,
    c(
      first_src[[1]], first_src[[2]],
      last_src[[3]], last_src[[4]],
      first_src[[5]], last_src[[6]],
      first_src[[7]], last_src[[8]]
    )
  )

  lines <- enc2utf8(as.character(src, useSource = TRUE))

  ## remove the first brace and line if the brace is the only thing on the line
  lines <- sub("^[{]", "", lines)
  if (!nzchar(lines[[1L]])) {
    lines <- lines[-1L]
  }

  ## identify the last source line affiliated with an expression
  n <- utils::getSrcLocation(last_src, which = "line", first = FALSE)

  ## rescue trailing comment on (current) last surviving line
  last_source_line <- getSrcLines(.srcfile, n, n) ## "raw"
  last_line <- lines[length(lines)] ## srcref'd
  m <- regexpr(last_line, last_source_line, fixed = TRUE)
  rescue_me <- substring(last_source_line, m + attr(m, "match.length"))
  if (grepl("^\\s*#", rescue_me)) {
    lines[length(lines)] <- paste0(last_line, rescue_me)
  }

  ## rescue trailing comment lines
  tail_lines <- getSrcLines(.srcfile, n + 1, Inf)
  closing_bracket_line <- max(grep("^\\s*[}]", tail_lines), 0)
  tail_lines <- utils::head(tail_lines, closing_bracket_line - 1)

  trim_common_leading_ws(c(lines, tail_lines))
}
