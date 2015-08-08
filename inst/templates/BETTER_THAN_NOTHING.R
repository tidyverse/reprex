#' No user-supplied code found ... so we've made some up! You're welcome.

#+ fortunes, include = requireNamespace("fortunes", quietly = TRUE)
fortunes::fortune()

#+ no-fortunes, include = !requireNamespace("fortunes", quietly = TRUE)
sprintf("Happy %s!", weekdays(Sys.Date()))

#+ safety-net, include = FALSE
# if(requireNamespace("fortunes", quietly = TRUE)) {
#   fortunes::fortune()
# } else {
#   sprintf("Happy %s!", weekdays(Sys.Date()))
# }
