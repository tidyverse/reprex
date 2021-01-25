# snapshot cli calls without explicitly starting an app

    Code
      getOption("cli.unicode")
    Output
      [1] FALSE
    Code
      getOption("crayon.enabled")
    Output
      [1] FALSE
    Code
      cli::cli_alert_success("SUCCESS!")
    Message <cliMessage>
      v SUCCESS!

# snapshot cli calls, but first start an app

    Code
      getOption("cli.unicode")
    Output
      [1] FALSE
    Code
      getOption("crayon.enabled")
    Output
      [1] FALSE
    Code
      cli::cli_alert_success("SUCCESS!")
    Message <cliMessage>
      v SUCCESS!

