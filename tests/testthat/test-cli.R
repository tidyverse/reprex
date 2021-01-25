test_that("snapshot cli calls without explicitly starting an app", {
  expect_snapshot({
    #cli::cli_sitrep()
    getOption("cli.unicode")
    getOption("crayon.enabled")
    cli::cli_alert_success("SUCCESS!")
  })
})

test_that("snapshot cli calls, but first start an app", {
  cli::start_app()
  expect_snapshot({
    #cli::cli_sitrep()
    getOption("cli.unicode")
    getOption("crayon.enabled")
    cli::cli_alert_success("SUCCESS!")
  })
})
