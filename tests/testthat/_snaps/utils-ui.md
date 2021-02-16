# reprex_alert() and friends work

    Code
      reprex_alert("alert", type = "")
    Message <cliMessage>
      > alert
    Code
      reprex_success("success")
    Message <cliMessage>
      v success
    Code
      reprex_info("info")
    Message <cliMessage>
      i info
    Code
      reprex_warning("warning")
    Message <cliMessage>
      ! warning
    Code
      reprex_danger("danger")
    Message <cliMessage>
      x danger

# reprex_alert() is under the control of REPREX_QUIET env var

    Code
      reprex_alert("alert", type = "")

---

    Code
      reprex_alert("alert", type = "")
    Message <cliMessage>
      > alert

# reprex_path() works and respects REPREX_QUIET

    Code
      reprex_path("Something descriptive:", "path/to/file")

---

    Code
      reprex_path("Something descriptive:", "path/to/file")
    Message <cliMessage>
      v Something descriptive:
        path/to/file
    Code
      x <- "path/to/file"
      reprex_path("Something descriptive:", x)
    Message <cliMessage>
      v Something descriptive:
        path/to/file
    Code
      y <- c("path", "to", "file")
      reprex_path("Something descriptive:", path_join(y))
    Message <cliMessage>
      v Something descriptive:
        path/to/file

