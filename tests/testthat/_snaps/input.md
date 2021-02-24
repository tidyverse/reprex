# reprex: expression input works

    Code
      cli::cat_line(reprex({
        x <- 1:5
        mean(x)
      }, render = FALSE))
    Output
      #' ---
      #' output: reprex::reprex_document
      #' ---
      
      x <- 1:5
      mean(x)

# reprex: character input works

    Code
      cli::cat_line(reprex(input = c("x <- 5:1", "mean(x)"), render = FALSE))
    Output
      #' ---
      #' output: reprex::reprex_document
      #' ---
      
      x <- 5:1
      mean(x)

# reprex: file input works

    Code
      cli::cat_line(reprex(input = "foo.R", render = FALSE))
    Output
      #' ---
      #' output: reprex::reprex_document
      #' ---
      
      x <- 6:10
      mean(x)

# reprex: file input in a subdirectory works

    Code
      cli::cat_line(reprex(input = path("foo", "foo.R"), render = FALSE))
    Output
      #' ---
      #' output: reprex::reprex_document
      #' ---
      
      x <- 11:15
      mean(x)

# Leading prompts are removed

    Code
      res2 <- reprex(input = input2, render = FALSE)
    Message <cliMessage>
      i Removing leading prompts from reprex source.

