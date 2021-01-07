Windows clipboard data persistence
================

Document what I learned about data persistence while writing to the
Windows clipboard

First, write a function to expose RTF on the clipboard from R, then call
it to establish baseline:

``` r
read_clipboard_rtf <- function() {
  stopifnot(.Platform$OS.type == "windows")
  system(
    'powershell -Command "Get-Clipboard -TextFormatType Rtf"',
    # `intern = TRUE` is a concession to knitr and making sure we see what
    # `Get-Clipboard` returns in our rendered result
    # it would not be necessary if you execute this interactively
    intern = TRUE)
}
read_clipboard_rtf()
#> character(0)
```

The approach I ultimately used in reprex based on the `SetText` method:

``` r
rtf <- r"({\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman;}} \f0\fs60 Hello, World!})"
cmd <- glue::glue('
  powershell -Command "\\
  Add-Type -AssemblyName System.Windows.Forms | Out-Null;\\
  [Windows.Forms.Clipboard]::SetText(\\
  \'{rtf}\',\\
  [Windows.Forms.TextDataFormat]::Rtf\\
  )"')
system(cmd)
#> [1] 0
read_clipboard_rtf()
#> [1] "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}} \\f0\\fs60 Hello, World!}"
```

The more complicated approach based on `SetDataObject`, before I
appreciated the persistence problem:

``` r
rtf <- r"({\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman;}} \f0\fs60 Hello, World!})"
cmd <- glue::glue('
  powershell -Command "\\
  Add-Type -AssemblyName System.Windows.Forms | Out-Null;\\
  $data = New-Object Windows.Forms.DataObject
  $data.SetData([Windows.Forms.DataFormats]::Rtf, \'{rtf}\')
  [Windows.Forms.Clipboard]::SetDataObject($data)"')
system(cmd)
#> [1] 0
read_clipboard_rtf()
#> character(0)
```

Adding the all important `$true` to the `SetDataObject` call:

``` r
rtf <- r"({\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman;}} \f0\fs60 Hello, World!})"
cmd <- glue::glue('
  powershell -Command "\\
  Add-Type -AssemblyName System.Windows.Forms | Out-Null;\\
  $data = New-Object Windows.Forms.DataObject
  $data.SetData([Windows.Forms.DataFormats]::Rtf, \'{rtf}\')
  [Windows.Forms.Clipboard]::SetDataObject($data, $true)"')
system(cmd)
#> [1] 0
read_clipboard_rtf()
#> [1] "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}} \\f0\\fs60 Hello, World!}"
```

Conclusion: `SetText` write persistent data, whereas by default
`SetDataObject` does not (although it can if you use the second
argument, `copy`).
