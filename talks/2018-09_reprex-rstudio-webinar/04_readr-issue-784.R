test1 <- "\"Header\nLine Two\"\nValue"
cat(test1)
readr::read_csv(test1)
