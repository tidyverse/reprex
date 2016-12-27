reprex_addin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Clock"),
    miniUI::miniContentPanel(
      shiny::uiOutput("time")
    )
  )

  server <- function(input, output, session) {

    # Set some CSS styles for our clock.
    clockStyles <- paste(
      "border: 1px solid #DADADA",
      "background-color: #EFEFEF",
      "border-radius: 5px",
      "font-size: 6em",
      "margin-top: 60px",
      "text-align: center",
      sep = "; "
    )

    # We'll use a 'reactiveTimer()' to force Shiny
    # to update and show the clock every second.
    invalidatePeriodically <- shiny::reactiveTimer(intervalMs = 1000)
    shiny::observe({

      # Call our reactive timer in an 'observe' function
      # to ensure it's repeatedly fired.
      invalidatePeriodically()

      # Get the time, and render it as a large paragraph element.
      time <- Sys.time()
      output$time <- shiny::renderUI({
        p(style = clockStyles, time)
      })
    })

    # Listen for 'done' events. When we're finished, we'll
    # insert the current time, and then stop the gadget.
    shiny::observeEvent(input$done, {
      timeText <- paste0("\"", as.character(Sys.time()), "\"")
      rstudioapi::insertText(timeText)
      shiny::stopApp()
    })

  }

  viewer <- shiny::dialogViewer("reprex")
  shiny::runGadget(ui, server, viewer = viewer)

}
