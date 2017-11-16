#' Render a reprex
#'
#' `reprex_addin()` opens a gadget that allows you to customise where the
#' code to reproduce should come from along with a handful of other options.
#' `reprex_selection()` reproduces the current selection, optionally
#' customised by options.
#'
#' An [RStudio gadget](https://shiny.rstudio.com/articles/gadgets.html) and
#' [addin](http://rstudio.github.io/rstudioaddins/) to call [reprex()]. Appears
#' as "Render reprex" in the RStudio Addins menu.
#' Prepare in one of these ways:
#'   * Copy reprex source to clipboard.
#'   * Select reprex source.
#'   * Activate the file containing reprex source.
#'   * Have source in a `.R` file.
#' Call [reprex()] directly for more control via additional arguments.
#'
#' @export
reprex_addin <- function() { # nocov start

  dep_ok <- vapply(c("rstudioapi", "shiny", "miniUI"),
                   requireNamespace, logical(1), quietly = TRUE)
  if (any(!dep_ok)) {
    stop("Install these packages in order to use the reprex addin:\n",
         paste(names(dep_ok[!dep_ok]), collapse = "\n"), call. = FALSE)
  }

  resource_path <- system.file("addins", package = "reprex")
  shiny::addResourcePath("reprex_addins", resource_path)

  ui <- miniUI::miniPage(
    shiny::tags$head(shiny::includeCSS(file.path(resource_path, "reprex.css"))),
    miniUI::gadgetTitleBar(
      shiny::p("Use",
               shiny::a(href = "https://github.com/tidyverse/reprex#readme",
                        "reprex"),
               "to render a bit of code"),
      right = miniUI::miniTitleBarButton("done", "Render", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shiny::radioButtons(
        "source",
        "Where is reprex source?",
        c("on the clipboard" = "clipboard",
          "current selection" = "cur_sel",
          "current file" = "cur_file",
          "another file" = "input_file")
      ),
      shiny::conditionalPanel(
        condition = "input.source == 'input_file'",
        shiny::fileInput(
          inputId = "source_file",
          label = "Source file"
        )
      ),
      shiny::radioButtons(
        "venue",
        "Target venue:",
        c("GitHub" = "gh",
          "Stack Overflow" = "so",
          "R script" = "r"),
        selected = getOption("reprex.venue", "gh")
      ),
      shiny::tags$hr(),
      shiny::checkboxInput(
        "si",
        "Append session info",
        getOption("reprex.si", FALSE)
      ),
      shiny::checkboxInput(
        "show",
        "Preview HTML",
        getOption("reprex.show", TRUE)
      )
    )
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      shiny::stopApp(list(
        input$source,
        input$venue,
        input$source_file,
        as.logical(input$si),
        as.logical(input$show)
      ))
    })
  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  result <- shiny::runGadget(app, viewer = shiny::dialogViewer("Render reprex"))

  do.call(reprex_guess, result)
}

reprex_guess <- function(source, venue = "gh", source_file = NULL,
                         si = FALSE, show = FALSE) {
  reprex_input <- switch(
    source,
    clipboard = NULL,
    cur_sel = rstudio_selection(),
    cur_file = rstudio_file(),
    input_file = source_file$datapath
  )

  reprex(
    input = reprex_input,
    venue = venue,
    si = si,
    show = show
  )
}

#' @export
#' @rdname reprex_addin
#' @inheritParams reprex
reprex_selection <- function(venue = getOption("reprex.venue", "gh"),
                             si = getOption("reprex.si", FALSE),
                             show = getOption("reprex.show", TRUE)) {
  reprex(
    input = rstudio_selection(),
    venue = venue,
    si = si,
    show = show
  )
}

# RStudio helpers ---------------------------------------------------------

rstudio_file <- function(context = rstudio_context()) {
  rstudio_text_tidy(context$contents)
}

rstudio_selection <- function(context = rstudio_context()) {
  text <- rstudioapi::primary_selection(context)[["text"]]
  rstudio_text_tidy(text)
}

rstudio_context <- function() {
  rstudioapi::getSourceEditorContext()
}

rstudio_text_tidy <- function(x) {
  Encoding(x) <- "UTF-8"
  x <- strsplit(x, "\n")[[1]]

  n <- length(x)
  if (!grepl("\n$", x[[n]])) {
    x[[n]] <- paste0(x[[n]], "\n")
  }
  x
}

# nocov end
