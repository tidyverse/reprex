ensure_not_empty <- function(x)
  if (length(x) < 1) read_from_template("BETTER_THAN_NOTHING") else x

ensure_not_dogfood <- function(x) {
  if (grepl("```", utils::tail(x, 1))) {
    stop("First three lines of putative code are:\n",
         paste(x[1:3], collapse = "\n"),
         "\nwhich isn't valid R code. Looks more like Markdown.\n",
         "Are we going in circles? Did you just run reprex()?\n",
         "In that case, the clipboard now holds the *rendered* result.\n",
         call. = FALSE)
  }
  x
}
