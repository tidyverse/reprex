# snapshot cli calls without explicitly starting an app

    Code
      cli::cli_sitrep()
    Output
      - cli_unicode_option : FALSE
      - symbol_charset     : ASCII (non UTF-8)
      - console_utf8       : TRUE
      - latex_active       : FALSE
      - num_colors         : 1
      - console_width      : 80
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
      [32m✓[39m SUCCESS!

# snapshot cli calls, but first start an app

    Code
      cli::cli_sitrep()
    Output
      - cli_unicode_option : FALSE
      - symbol_charset     : ASCII (non UTF-8)
      - console_utf8       : TRUE
      - latex_active       : FALSE
      - num_colors         : 1
      - console_width      : 80
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

