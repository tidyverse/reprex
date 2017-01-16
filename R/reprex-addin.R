#' Render a reprex
#'
#' An \href{https://shiny.rstudio.com/articles/gadgets.html}{RStudio gadget} and
#' \href{http://rstudio.github.io/rstudioaddins/}{addin} to call
#' \code{\link{reprex}()}. Appears as "Render reprex" in the RStudio Addins
#' menu.
#' Prepare in one of these ways:
#' \enumerate{
#' \item Copy reprex source to clipboard.
#' \item Select reprex source.
#' \item Activate the file containing reprex source.
#' \item Have source in a \code{.R} file.
#' }
#' Call \code{\link{reprex}()} directly for more control via additional
#' arguments.
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
               shiny::a(href = "https://github.com/jennybc/reprex#readme",
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
          "StackOverflow" = "so",
          "R script" = "r")
      ),
      shiny::tags$hr(),
      shiny::checkboxInput(
        "si",
        "Append session info",
        FALSE
      ),
      shiny::checkboxInput(
        "show",
        "Preview HTML",
        TRUE
      )
    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent(input$done, {
      reprex_output <- reprex_guess(
        input$source,
        input$venue,
        input$source_file,
        as.logical(input$si),
        as.logical(input$show)
      )

      shiny::showModal(
        shiny::modalDialog(
          "Rendered reprex is on the clipboard.",
          footer = shiny::actionButton("ok", "OK")
        )
      )
      #reprex_output <- paste(reprex_output, collapse = "\n")
      #rstudioapi::insertText(Inf, reprex_output, id = context$id)
    })

    shiny::observeEvent(input$ok, {
      invisible(shiny::stopApp())
    })

  }

  shiny::runGadget(ui, server, viewer = shiny::dialogViewer("Render reprex"))

}

reprex_guess <- function(source, venue = "gh", source_file = NULL,
                         si = FALSE, show = FALSE) {
  context <- rstudioapi::getSourceEditorContext()

  reprex_input <- switch(
    source,
    clipboard = NULL,
    cur_sel = newlined(rstudioapi::primary_selection(context)[["text"]]),
    cur_file = newlined(context$contents),
    input_file = source_file$datapath
  )

  reprex(
    input = reprex_input,
    venue = venue,
    si = si,
    show = show
  )
}
# nocov end
