optionally <- function(default) default

resolve <- function(nm) {
  cl <- sys.call(-1)
  f <- sys.function(-1)
  formal <- formals(f)
  actual <- as.list(match.call(f, cl))
  eval(actual[[nm]]) %||% getOption(nm) %||% eval(formal[[nm]])
}

