## WARNING! WARNING!
## ALL OF THIS IS SPECIFIC TO MAC OS RIGHT NOW!

cb_clear <- function() {
  system("pbcopy < /dev/null")
}

cb_read <- function() {
  con <- pipe("pbpaste")
  ## use scan instead of readLines so lack of terminating EOL is no biggie
  ## saw this in https://github.com/kevinushey/Kmisc/blob/master/R/misc.R
  contents <- scan(con, what = character(), sep = "\n",
                   blank.lines.skip = FALSE, quiet = TRUE)
  close(con)
  contents
}

cb_write <- function(x) {
  con <- pipe("pbcopy")
  cat(x, file = con, sep = "\n")
  close(con)
}

# Relevant bits from official help re: connections
#
# file can be used with description = "clipboard" in mode "r" only. This reads
# the X11 primary selection (see
# http://standards.freedesktop.org/clipboards-spec/clipboards-latest.txt), which
# can also be specified as "X11_primary" and the secondary selection as
# "X11_secondary". On most systems the clipboard selection (that used by ‘Copy’
# from an ‘Edit’ menu) can be specified as "X11_clipboard".
#
# When a clipboard is opened for reading, the contents are immediately copied to
# internal storage in the connection.
#
# Unix users wishing to write to one of the selections may be able to do so via
# xclip (http://sourceforge.net/projects/xclip/), for example by pipe("xclip
# -i", "w") for the primary selection.
