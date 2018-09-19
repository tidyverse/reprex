x <- factor("a")
y <- factor("b")
c(x, y)

factor(c(as.character(x), as.character(y)))
forcats::fct_c(x, y)
