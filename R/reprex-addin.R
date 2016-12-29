#' Render a reprex
#'
#' An \href{https://shiny.rstudio.com/articles/gadgets.html}{RStudio gadget} and
#' \href{http://rstudio.github.io/rstudioaddins/}{addin} to call
#' \code{\link{reprex}()}. Meant to be activated from the RStudio Addins menu.
#' Prepare in one of these ways:
#' \enumerate{
#' \item Copy reprex source to clipboard.
#' \item Select reprex source.
#' \item Activate the file containing reprex source.
#' }
#' Call \code{\link{reprex}()} directly for more control via additional
#' arguments.
#'
#' @export
reprex_addin <- function() {

  dep_ok <- vapply(c("rstudioapi", "shiny", "miniUI", "shinyjs"),
                   requireNamespace, logical(1), quietly = TRUE)
  if (any(!dep_ok)) {
    stop("Install these packages in order to use the reprex addin:\n",
         paste(names(dep_ok[!dep_ok]), collapse = "\n"), call. = FALSE)
  }

  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
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
          "current file" = "cur_file")
        # TO DO
        # "another file" = "infile")
      ),
      shiny::radioButtons(
        "venue",
        "Target venue:",
        c("GitHub" = "gh",
          "StackOverflow" = "so")
      ),
      shiny::tags$hr(),
      shiny::checkboxInput(
        "si",
        "Append session info:",
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

      context <- rstudioapi::getSourceEditorContext()

      reprex_input <- shiny::reactive({
        switch(
          input$source,
          cur_sel = list(input = newlined(
            rstudioapi::primary_selection(context)[["text"]]
            )),
          cur_file = list(input = newlined(context$contents)),
          ## TODO: figure out how to get a file selection dialog
          infile = list(input = "mean(rnorm(10))\n")
        )
      })

      ## make my list of args here, like so
      reprex_args <- c(
        reprex_input(),
        list(
          venue = input$venue,
          si = as.logical(input$si),
          show = as.logical(input$show)
        )
      )

      reprex_output <- do.call(reprex, reprex_args)
      shinyjs::info("reprex() output ready on clipboard")
      #reprex_output <- paste(reprex_output, collapse = "\n")
      #rstudioapi::insertText(Inf, reprex_output, id = context$id)
      invisible(shiny::stopApp())

    })

  }

  shiny::runGadget(ui, server, viewer = shiny::dialogViewer("Render reprex"))

}
