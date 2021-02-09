# Run before any test
op <- options("reprex.clipboard" = FALSE)

# Run after all tests
withr::defer(options(op), teardown_env())
