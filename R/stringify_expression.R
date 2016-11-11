## input is quoted()'ed expression
## reprex() takes care of that or, to use directly:
## q <- quote({a + b})
stringify_expression <- function(q) {
  src <- attr(q, "srcref")

  ## if input is, eg 1:5, there is no srcref
  if (is.null(src)) {
    return(deparse(q))
  }

  ## https://journal.r-project.org/archive/2010-2/RJournal_2010-2_Murdoch.pdf
  ## Each element is a vector of 6 integers: (first line, first byte, last line,
  ## last byte, first character, last character)
  ## ^^ clearly not whole story because I see vectors of length 8
  ## but seems to be true description of first 6 elements
  coord <- do.call(rbind, lapply(src, `[`, c(1, 5, 3, 6)))
  colnames(coord) <- c("first_line", "first_character",
                       "last_line", "last_character")
  n_statements <- nrow(coord)
  ## each row holds coordinates of source for one statement

  ## all statements seem to contain such a reference to same lines of source
  lines <-  attr(src[[1]], "srcfile")$lines

  ## make sure source is split into character vector anticipated by coord
  if (!isTRUE(attr(src[[1]], "srcfile")$fixedNewlines)) {
    lines <- strsplit(lines, split = "\n")[[1]]
  }

  lines <- lines[coord[1, "first_line"]:coord[n_statements, "last_line"]]

  ## line 1 needs to be pruned, possibly from both ends
  ## default is this in order to retain end of line comments
  line_1_end <- nchar(lines[1])
  ## but still have to worry about multiple statements in one line, eg {1:5;6:9}
  if (n_statements > 1 && coord[2, "last_line", drop = TRUE] == 1) {
    line_1 <- coord[ , "last_line", drop = TRUE] == 1
    line_1_end <- max(coord[line_1, "last_character"])
  }
  lines[1] <- substr(lines[1], coord[1, "first_character"], line_1_end)
  lines[1] <- sub("^\\{", "", lines[1])

  ## last line may also need to be truncated
  n_lines <- length(lines)
  ## but don't do anything if line 1 == last line
  if (n_statements > 1 && n_lines > 1) {
    lines[n_lines] <- substr(lines[n_lines],
                             coord[n_statements, "first_character"],
                             coord[n_statements, "last_character"])
  }

  ## this needs to happen after (possibly) truncating last line
  if (lines[1] == "" || grepl("^\\s+$", lines[1])) {
    lines <- lines[-1]
  }
  lines
}
