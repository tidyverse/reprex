#' Render a reprex, conveniently
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
#'   Suggested shortcut: Cmd + Shift + R (macOS) or Ctrl + Shift + R (Windows).
#'
#' @export
reprex_addin <- function() { # nocov start

  check_installed(
    c("shiny", "miniUI"),
    "in order to use the reprex addin"
  )
  resource_path <- path_package("reprex", "addins")
  shiny::addResourcePath("reprex_addins", resource_path)

  ui <- miniUI::miniPage(
    shiny::tags$head(shiny::includeCSS(path(resource_path, "reprex.css"))),
    miniUI::gadgetTitleBar(
      shiny::p(
        "Use",
        shiny::a(href = "https://reprex.tidyverse.org", "reprex"),
        "to render a bit of code"
      ),
      right = miniUI::miniTitleBarButton("done", "Render", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shiny::radioButtons(
        "source",
        "Where is reprex source?",
        c(
          "on the clipboard" = if (reprex_clipboard()) "clipboard",
          "current selection" = "cur_sel",
          "current file" = "cur_file",
          "another file" = "input_file"
        )
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
        c(
          "GitHub or Stack Overflow" = "gh",
          "R script (output appears as comments)" = "r",
          "HTML" = "html",
          "Rich Text Format" = "rtf",
          "Slack message" = "slack"
        ),
        selected = getOption("reprex.venue", "gh")
      ),
      shiny::tags$hr(),
      shiny::checkboxInput(
        "session_info",
        "Append session info",
        getOption("reprex.session_info", FALSE)
      ),
      shiny::checkboxInput(
        "html_preview",
        "Preview HTML",
        getOption("reprex.html_preview", TRUE)
      )
    )
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      shiny::stopApp(reprex_guess(
        input$source,
        input$venue,
        input$source_file,
        as.logical(input$session_info),
        as.logical(input$html_preview)
      ))
    })
  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  shiny::runGadget(app, viewer = shiny::dialogViewer("Render reprex"))
}

reprex_guess <- function(source, venue = "gh", source_file = NULL,
                         session_info = FALSE, html_preview = FALSE) {
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
    session_info = session_info,
    html_preview = html_preview
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
# nocov end

rstudio_text_tidy <- function(x) {
  if (x == "") {
    return(character())
  }
  Encoding(x) <- "UTF-8"
  if (length(x) == 1) {
    ## rstudio_selection() returns catenated text
    x <- strsplit(x, "\n")[[1]]
  }

  n <- length(x)
  if (!grepl("\n$", x[[n]])) {
    x[[n]] <- newline(x[[n]])
  }
  x
}

