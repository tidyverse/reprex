#' Render a reprex
#'
#' @description `reprex_addin()` opens an [RStudio
#'   gadget](https://shiny.rstudio.com/articles/gadgets.html) and
#'   [addin](http://rstudio.github.io/rstudioaddins/) that allows you to say
#'   where the reprex source is (clipboard? current selection? active file?
#'   other file?) and to control a few other arguments. Appears as "Render
#'   reprex" in the RStudio Addins menu.
#'
#' @description `reprex_selection()` is an
#'   [addin](http://rstudio.github.io/rstudioaddins/) that reprexes the current
#'   selection, optionally customised by options. Appears as "Reprex selection"
#'   in the RStudio Addins menu. Heavy users might want to [create a keyboard
#'   shortcut](https://support.rstudio.com/hc/en-us/articles/206382178-Customizing-Keyboard-Shortcuts).
#'
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
               shiny::a(href = "http://reprex.tidyverse.org", "reprex"),
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
    source_file <- reactive({
      if (is.null(input$source_file$datapath)) return(NULL)
      readLines(input$source_file$datapath)
    })

    shiny::observeEvent(input$done, {
      shiny::stopApp(list(
        source = input$source,
        venue = input$venue,
        source_from_file = source_file(),
        si = as.logical(input$si),
        show = as.logical(input$show)
      ))
    })
  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  rep <- shiny::runGadget(app, viewer = shiny::dialogViewer("Render reprex"))

  # browser()
  reprex_guess(
    source = rep$source,
    venue = rep$venue,
    source_from_file = rep$source_from_file,
    si = rep$si,
    show = rep$show
  )
}

reprex_guess <- function(source, venue = "gh", source_from_file = NULL,
                         si = FALSE, show = FALSE) {
  reprex_input <- switch(
    source,
    clipboard = NULL,
    cur_sel = rstudio_selection(),
    cur_file = rstudio_file(),
    input_file = source_from_file
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
reprex_selection <- function(venue = getOption("reprex.venue", "gh")) {
  reprex(input = rstudio_selection(), venue = venue)
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
  if (length(x) == 1) {
    ## rstudio_selection() returns catenated text
    x <- strsplit(x, "\n")[[1]]
  }

  n <- length(x)
  if (!grepl("\n$", x[[n]])) {
    x[[n]] <- paste0(x[[n]], "\n")
  }
  x
}

# nocov end
