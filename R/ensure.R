ensure_not_empty <- function(x)
  if (length(x) < 1) read_from_template("BETTER_THAN_NOTHING") else x

ensure_not_dogfood <- function(x) {
  looks_like_gh <- any(grepl("^```", x))
  looks_like_so <- any(grepl("<!-- language-all: lang-r -->", x))
  if (looks_like_gh || looks_like_so) {
    stop("First three lines of putative code are:\n",
         paste(x[1:3], collapse = "\n"),
         "\nwhich isn't valid R code.\n",
         "Are we going in circles? Did you just run reprex()?\n",
         "In that case, the clipboard now holds the *rendered* result.\n",
         call. = FALSE)
  }
  x
}
