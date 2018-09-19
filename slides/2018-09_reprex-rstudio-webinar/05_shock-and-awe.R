#+ eval = FALSE
## figures are uploaded to imgur.com and linked, by default
library(gapminder)
library(ggplot2)

ggplot(subset(gapminder, continent != "Oceania"),
       aes(x = year, y = lifeExp, group = country, color = country)) +
  geom_line(lwd = 1, show.legend = FALSE) + facet_wrap(~ continent) +
  scale_color_manual(values = country_colors) +
  theme_bw() + theme(strip.text = element_text(size = rel(1.1)))

## copy the above ^^ to clipboard
reprex()
## paste into, e.g., GitHub issue
## OMG the figure is there! w00t!

#+ eval = FALSE
## provide input as an expression
reprex({
  x <- rnorm(100)
  y <- rnorm(100)
  cor(x, y)
})

#+ eval = FALSE
## ask to work in working directory (vs session temp directory)
## helpful if reprex does file I/O
reprex(
  writeLines(letters[1:6]),
  outfile = NA
)

## provide a humane base for the filename
reprex(
  writeLines(letters[21:26]),
  outfile = "shock-and-awe"
)

#+ eval = FALSE
## render to markdown tuned to Stack Overflow (vs GitHub or Discourse)
reprex(
  mean(rnorm(100)),
  venue = "so"
)

## render to a commented R script
## great for email or Slack
reprex(
  mean(rnorm(100)),
  venue = "r"
)

## render to RTF to paste into Keynote or PowerPoint
reprex(
  mean(rnorm(100)),
  venue = "rtf"
)

#+ eval = FALSE
## suppress the "advertisement" (toggle it!)
reprex(
  mean(rnorm(100)),
  advertise = TRUE
)

## include session info (toggle it!)
reprex(
  mean(rnorm(100)),
  si = TRUE
)

## re-style the code  (toggle it!)
reprex(
  input = c(
    'if (TRUE) "true branch" else {',
    '"else branch"',
    '              }'
  ),
  style = TRUE
)

## whimsical comment string ;-)
reprex(
  cat(letters[1:3], sep = "\n"),
  comment = "#;-)"
)

## suppress tidyverse startup messaging (or not ... toggle it!)
reprex(
  library(tidyverse),
  tidyverse_quiet = TRUE
)

#+ eval = FALSE
## include output from standard output and standard error
remove.packages("bench")
reprex(
  devtools::install_github("r-lib/bench"),
  std_out_err = TRUE
)
