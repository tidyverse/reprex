# Run before any test
op <- options(reprex.clipboard = FALSE, reprex.html_preview = FALSE)

# Run after all tests
withr::defer(options(op), teardown_env())
