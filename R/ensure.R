ensure_not_empty <- function(x) {
  if (length(x) < 1) read_template("BETTER_THAN_NOTHING") else x
}

ensure_not_dogfood <- function(x) {
  looks_like_gh <- any(grepl("^```", x))
  looks_like_so <- any(grepl("<!-- language-all: lang-r -->", x))
  if (looks_like_gh || looks_like_so) {
    ## I negate yep(), instead of using nope(), to get desired behaviour in
    ## a non-interactive call
    if (!yep(
      "First three lines of putative code are:\n",
      paste(x[1:3], collapse = "\n"),
      "\nwhich doesn't look like R code.\n",
      "Are we going in circles? Did you just run reprex()?\n",
      "In that case, the clipboard now holds the *rendered* result.\n",
      "Carry on with this reprex?"
    )) {
      abort("Aborting.")
    }
  }

  looks_like_r <- any(grepl("^#>", x))
  if (looks_like_r) {
    if (!yep(
      "Putative code contains lines that start with `#>`.\n",
      "Are we going in circles? Did you just run `reprex(..., venue = \"r\")`?\n",
      "In that case, the clipboard now holds the *rendered* result.\n",
      "Carry on with this reprex?"
    )) {
      abort("Aborting.")
    }
  }
  x
}

ensure_no_prompts <- function(x, prompt = getOption("prompt")) {
  regex <- paste0("^", escape_regex(prompt))
  prompts <- grepl(regex, x)
  if (any(prompts)) {
    message("Removing leading prompts from reprex source.")
  }
  sub(regex, "", x)
}

ensure_stylish <- function(x) {
  if (requireNamespace("styler", quietly = TRUE)) {
    x <- styler::style_text(x)
  } else {
    message("Install the styler package in order to use `style = TRUE`.")
  }
  x
}
