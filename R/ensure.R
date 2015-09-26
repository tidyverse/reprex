ensure_not_empty <- function(x)
  if (length(x) < 1) read_from_template("BETTER_THAN_NOTHING") else x

ensure_not_dogfood <- function(x) {
  if(grepl("```", x[[length(x)]])) {
    stop(paste(
      "\nFirst three lines of putative code are:\n",
      x[1], x[2], x[3],
      "\nwhich isn't valid R code. Look more like Markdown.",
      "Are we going in circles? Did you just run reprex()?",
      "In that case, the clipboard now holds the *rendered* result.",
      sep = "\n"))
  } else {
    x
  }
}
