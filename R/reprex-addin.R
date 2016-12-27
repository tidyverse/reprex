reprex_addin <- function() {

  reprex_link <- tags$a(href = "https://github.com/jennybc/reprex#readme", "reprex")

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Prepare a reprex"),
    miniUI::miniContentPanel(
      h4("Use ", reprex_link, " to render snippets of code."),
      hr(),
      selectInput("source",
                  "Where is reprex source?",
                  c("clipboard", "current selection",
                    "current file", "another file")
      ),
      uiOutput("document", container = rCodeContainer),
      miniUI::miniButtonBlock(
        actionButton("reprex", "Render")
      )
    )
  )

  server <- function(input, output, session) {

    context <- rstudioapi::getActiveDocumentContext()

    reactiveDocument <- reactive({

      reprex_source <- input$source

      if (identical(reprex_source, "clipboard")) {
        res <- reprex()
      } else {
        res <- reprex(src = "mean(rnorm(10))")
      }
      res
    })

    output$document <- renderCode({
      document <- reactiveDocument()
      document
    })

    shiny::observeEvent(input$done, {
      contents <- paste(reactiveDocument(), collapse = "\n")
      rstudioapi::setDocumentContents(contents, id = context$id)
      invisible(shiny::stopApp())
    })

  }

  viewer <- shiny::dialogViewer("Reformat Code", width = 1000, height = 800)
  shiny::runGadget(ui, server, viewer = viewer)

}

rCodeContainer <- function(...) {
  code <- shiny::HTML(as.character(tags$code(class = "language-r", ...)))
  shiny::div(shiny::pre(code))
}

renderCode <- function(expr, env = parent.frame(), quoted = FALSE) {
  func <- NULL
  shiny::installExprFunction(expr, "func", env, quoted)
  shiny::markRenderFunction(textOutput, function() {
    paste(func(), collapse = "\n")
  })
}
