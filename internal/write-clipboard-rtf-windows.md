Putting RTF on the Windows clipboard
================

We need to put RTF on the clipboard for `reprex(venue = "rtf")`, a.k.a.
`reprex_rtf()`. This appears to happen automagically on macOS,
i.e. `pbcopy` detects the RTF file header and automatically writes RTF
to the appropriate pasteboard. Alas, this doesn’t “just work” for us on
Windows, because clipr calls `utils::writeClipboard()` and R does not
even register the RTF format (although it could).

We have to shell out for this, which is a bit gross, but clipr shells
out to, e.g., `pbcopy` and reprex already shells out in order to call
highlight. This whole RTF feature is already a bit hacky, so I’m not
fussed about adding another `system()` call.

At first, you think you can use the [`Set-Clipboard` PowerShell
cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-clipboard?view=powershell-5.1),
but you can’t because it does not support writing rich text. Interesting
observations:

-   `Set-Clipboard` **can write HTML**: `Set-Clipboard -AsHtml`. This
    could be another way to produce syntax-highlighted, hyperlinked
    output in reprex, e.g. if we start using downlit.
-   The [`Get-Clipboard`
    cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-clipboard?view=powershell-5.1)
    **can read RTF** content from the clipboard:
    `Get-Clipboard -TextFormatType Rtf`.

We will have to exert ourselves a bit to write RTF to the Windows
clipboard. We use PowerShell to access the .NET framework and,
specifically, to work with classes and methods from the
`System.Windows.Forms` namespace. It feels like the “right” way to do
this would be to write a PowerShell *script*, but there are a couple of
downsides. First, it’s not conventional to ship and execute a PowerShell
script from within an R package. Second – the real dealkiller – is the
need to deal with the PowerShell execution policy. Therefore we actually
construct a rather ugly one-liner and execute it via `system()`.

## Generate some RTF

If you have the highlight command line utility installed and on the path
and the dev version of reprex, this will work:

``` r
library(reprex)
reprex_rtf({x <- rnorm(10); mean(x)}, outfile = here::here("rnorm"))
#> Non-interactive session, setting `html_preview = FALSE`.
#> Preparing reprex as .R file:
#>   * C:/Users/jenny/Desktop/reprex/rnorm_reprex.R
#> Rendering reprex...
#> Writing reprex file:
#>   * C:/Users/jenny/Desktop/reprex/rnorm_reprex.rtf
```

Otherwise this code writes a minimal RTF file to work with:

``` r
# using literal string feature from R 4.0
minimal_rtf <- r"({\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman;}} \f0\fs60 Hello, World!})"
writeLines(minimal_rtf, here::here("minimal.rtf"))
```

Hopefully we’ve got at least one RTF file now:

``` r
list.files(here::here(), pattern = "[.]rtf$")
#> [1] "minimal.rtf"      "rnorm_reprex.rtf"
```

## The Solution

After much struggle, I finally reached this simple-but-hacky solution to
write the contents of an RTF file onto the RTF part of the Windows
clipboard.

``` r
write_clipboard_rtf <- function(path) {
  stopifnot(.Platform$OS.type == "windows")
  cmd <- glue::glue('
    powershell -Command "\\
    Add-Type -AssemblyName System.Windows.Forms | Out-Null;\\
    [Windows.Forms.Clipboard]::SetText(
    (Get-Content {path}),\\
    [Windows.Forms.TextDataFormat]::Rtf
    )"')
  res <- system(cmd)
  if (res > 0) {
    stop("Failed to put RTF on the Windows clipboard", call. = FALSE)
  }
  invisible(res)
}
```

The function above is essentially what we use in reprex.

Let’s create a function to expose the RTF part of the Windows clipboard:

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
```

Finally, let’s show that we can put our RTF onto the Windows clipboard.

``` r
write_clipboard_rtf(here::here("rnorm_reprex.rtf"))
read_clipboard_rtf()
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier Regular;}}{\\colortbl;\\red00\\green00\\blue00;\\red160\\green160\\blue192;\\red208\\green224\\blue128;\\red208\\green224\\blue128;\\red96\\green96\\blue128;\\red96\\green96\\blue128;\\red128\\green128\\blue128;\\red160\\green160\\blue192;\\red208\\green224\\blue128;\\red96\\green96\\blue128;\\red204\\green204\\blue204;\\red207\\green165\\blue219;\\red128\\green144\\blue240;\\red224\\green224\\blue255;\\red159\\green191\\blue175;} \\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs100 \\pard \\cbpat1{{\\cf2{x}} {\\cf11{<-}} {\\cf2{}}{\\cf15{rnorm}}{\\cf2{}}{\\cf11{(}}{\\cf2{}}{\\cf4{{1}{0}}}{\\cf2{}}{\\cf11{);}} {\\cf2{}}{\\cf15{mean}}{\\cf2{}}{\\cf11{(}}{\\cf2{x}}{\\cf11{)}}}\\par\\pard \\cbpat1{{\\cf2{}}{\\cf5{#> [{1}] {0}.{6}{4}{2}{7}{5}{2}{8}}}{\\cf2{}}}}"

write_clipboard_rtf(here::here("minimal.rtf"))
read_clipboard_rtf()
#> [1] "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}} \\f0\\fs60 Hello, World!}"
```

Clean up.

``` r
unlink(list.files(here::here(), pattern = "rnorm_reprex", full.names = TRUE))
unlink(here::here("minimal.rtf"))
```

## The Struggle

I never want to re-learn all of this again from scratch, so here are
some notes for the future.

### A working script and `Add-Type`

My first goal was to get a working PowerShell script, even though I knew
I’d eventually need a one-liner. I started with a much more complicated
script (see later), but eventually got to this one. I save this as
`write_clipboard_rtf_alfa.ps1`.

    Add-Type -AssemblyName System.Windows.Forms
    $rtf = Get-Content -Path alfa_reprex.rtf
    [Windows.Forms.Clipboard]::SetText($rtf, [System.Windows.Forms.TextDataFormat]::Rtf)

(If I were really writing such a script, of course I wouldn’t hard-wire
the RTF filename like this. I’d take a path or perhaps the RTF string
via standard input or some such. But this script is just a stepping
stone here.)

Create an RTF file that we want to load onto the clipboard.

``` r
reprex::reprex_rtf(sample(LETTERS, 5), outfile = here::here("internal/alfa"))
#> Non-interactive session, setting `html_preview = FALSE`.
#> Preparing reprex as .R file:
#>   * C:/Users/jenny/Desktop/reprex/internal/alfa_reprex.R
#> Rendering reprex...
#> Writing reprex file:
#>   * C:/Users/jenny/Desktop/reprex/internal/alfa_reprex.rtf
```

In an interactive PowerShell instance, we could then execute the script
like so (at least, once you’ve set the session execution policy to allow
this):

``` pwsh
.\write_clipboard_rtf_alfa.ps1
```

Invoke this script from R and inspect the RTF clipboard.

``` r
system(r"(powershell -Command ".\write_clipboard_rtf_alfa.ps1")")
#> [1] 0
read_clipboard_rtf()
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier Regular;}}{\\colortbl;\\red00\\green00\\blue00;\\red160\\green160\\blue192;\\red208\\green224\\blue128;\\red208\\green224\\blue128;\\red96\\green96\\blue128;\\red96\\green96\\blue128;\\red128\\green128\\blue128;\\red160\\green160\\blue192;\\red208\\green224\\blue128;\\red96\\green96\\blue128;\\red204\\green204\\blue204;\\red207\\green165\\blue219;\\red128\\green144\\blue240;\\red224\\green224\\blue255;\\red159\\green191\\blue175;} \\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs100 \\pard \\cbpat1{{\\cf2{}}{\\cf15{sample}}{\\cf2{}}{\\cf11{(}}{\\cf2{LETTERS}}{\\cf11{,}} {\\cf2{}}{\\cf4{{5}}}{\\cf2{}}{\\cf11{)}}}\\par\\pard \\cbpat1{{\\cf2{}}{\\cf5{#> [{1}] \"O\" \"N\" \"F\" \"Z\" \"H\"}}{\\cf2{}}}}"
```

IT’S WORKING!

Here’s how that looks in one-liner form, i.e. as something you could
execute in PowerShell or `cmd.exe` or from R with `system()`:

``` pwsh
powershell -Command "Add-Type -AssemblyName System.Windows.Forms | Out-Null;[Windows.Forms.Clipboard]::SetText((Get-Content alfa_reprex.rtf),[Windows.Forms.TextDataFormat]::Rtf)"
```

If you execute `write_clipboard_rtf_alfa.ps1` from an interactive
PowerShell instance, this first line is actually unnecessary:

``` pwsh
Add-Type -AssemblyName System.Windows.Forms
```

But AFAICT, most other ways of executing the script require this line to
work. I learned this the hard way. For example, this line is needed if
you want to execute this in an interactive `cmd.exe` shell:

    powershell -File write_clipboard_rtf_alfa.ps1

I believe `Add-Type -AssemblyName System.Windows.Forms` is required for
any of the ways we might eventually execute this from R.

I learned about this line and other tricks for smushing such a script
into a one-liner by [asking this question on Stack
Overflow](https://stackoverflow.com/q/65543792/2825349). You’ll also
notice at that time, I was working with a much more convoluted approach
to writing RTF to the clipboard (more below).

Clean up.

``` r
unlink(list.files(here::here("internal"), pattern = "alfa_reprex", full.names = TRUE))
```

## A more complicated and worse solution

The first working script that I wrote was actually much more complicated
and demonstrably worse. It looked something like this, which I save to
`write_clipboard_rtf_beta.ps1`:

    Add-Type -AssemblyName "System.Windows.Forms"
    $data = New-Object Windows.Forms.DataObject
    $rtf = Get-Content -Path beta_reprex.rtf
    $data.SetData([Windows.Forms.DataFormats]::Rtf, $rtf)
    [Windows.Forms.Clipboard]::SetDataObject($data)

Here I instantiate a new `DataObject`, add the RTF to it, then set the
clipboard to this object. In addition to being more convoluated, this
had a huge functional problem: the RTF disappears from the clipboard as
soon as the PowerShell exits. During interactive development, you don’t
notice this, but it means the approach basically doesn’t work from R.

This was very hard to figure out. To prove to myself that I was, indeed,
writing the RTF to the clipboard, I inserted this at the end the script:

``` pwsh
Get-Clipboard -TextFormatType Rtf
```

And I could see even from R that the RTF *was* being stored on the
clipboard. Briefly.

Once I figured out the persistence problem, I added some sleep to keep
the PowerShell alive for a while, with this line:

``` pwsh
Start-Sleep -Seconds 60
```

Then I had to direct R *not* to wait for the `command` to finish like
so:

``` r
system(..., wait = FALSE)
```

Then you had one minute after calling `reprex_rtf()` to paste the RTF
somewhere.

Luckily using the simpler approach to writing rich text to the clipboard
also solved the persistence problem at the same time.

But if I ever need the more complicated version – maybe to write an
image? – I’d have to grapple with this. I think there might be a way to
request persistence FILL THIS IN. This would also go away if we were
accessing the clipboard more directly.

## What PowerShell are we talking about?

Windows PowerShell ships with Windows and is not the same thing as
PowerShell Core. Pragmatically, they are very similar, but if things
don’t seem to work as documented, consider that you are reading the docs
for the wrong one. When we shell out to `powershell` from R, we are
using Windows PowerShell. On my Windows 10 VM, I have Windows PowerShell
5.1. If my solution doesn’t work for people on different versions of
Windows, consider that this may be due to their having a different
version of Windows PowerShell.