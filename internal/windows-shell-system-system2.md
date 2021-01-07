Running an external process on Windows
================

Figuring out how to write RTF to the Windows clipboard made me think
more about the functions `system()`, `system2()`, and (Windows only)
`shell()`.

Here’s the highlight call used in `reprex_rtf()`, which converts such a
`.R` file into RTF:

``` sh
highlight -i foo_reprex.R --out-format rtf --no-trailing-nl --encoding=UTF-8 --style darkbone --font 'Courier Regular' --font-size 50 -o gamma_reprex.rtf
```

There are many ways to invoke this from R:

-   `system()`: Docs say “not recommended for new code”.
-   `system2()`: Officially, the “right” thing to use, at least on
    \*nix.
-   `shell()`: Exists only on Windows. Explicitly runs `cmd` under a
    shell, which is not the case for `system()` or `system2()` on
    Windows.
-   `processx::run()`

`system()` and `system2()` only differ with respect to how the
ultimately-run command is constructed. `system2()` is recommended for
new code and takes care of some fiddly details, e.g. quoting. However,
due to quoting nightmares, there are calls that can only be formed by
`system()` and some that can’t be formed at all (which is one of the
reasons processx exists). The main thing to know is that on Windows
`command` is executed directly, not within a shell, such as `cmd.exe` or
`powershell.exe`.

This is easiest to see in an example. `dir` is a command built into
`cmd.exe`. It will work inside `shell()` but not within `system()` or
`system2()`.

``` r
shell("dir", intern = TRUE)
#>  [1] " Volume in drive C has no label."                                             
#>  [2] " Volume Serial Number is 64AE-6712"                                           
#>  [3] ""                                                                             
#>  [4] " Directory of C:\\Users\\jenny\\Desktop\\reprex\\internal"                    
#>  [5] ""                                                                             
#>  [6] "01/07/2021  03:27 PM    <DIR>          ."                                     
#>  [7] "01/07/2021  03:27 PM    <DIR>          .."                                    
#>  [8] "01/01/2021  03:04 PM             2,895 language-codes.csv"                    
#>  [9] "01/01/2021  03:04 PM            54,239 logo.png"                              
#> [10] "01/01/2021  03:04 PM               616 message-language-probe.R"              
#> [11] "01/01/2021  03:04 PM             2,094 notes.md"                              
#> [12] "01/07/2021  10:22 AM             1,980 render-notes.txt"                      
#> [13] "01/01/2021  03:04 PM               711 vignette-ideas.Rmd"                    
#> [14] "01/07/2021  12:32 PM             2,487 windows-clipboard-data-persistence.md" 
#> [15] "01/07/2021  12:30 PM             2,434 windows-clipboard-data-persistence.Rmd"
#> [16] "01/07/2021  02:39 PM             4,528 windows-shell-system-system2.md"       
#> [17] "01/07/2021  03:25 PM             3,962 windows-shell-system-system2.Rmd"      
#> [18] "01/07/2021  11:09 AM            15,330 write-clipboard-rtf-windows.md"        
#> [19] "01/07/2021  10:23 AM               173 write_clipboard_rtf_alfa.ps1"          
#> [20] "01/07/2021  10:23 AM               238 write_clipboard_rtf_beta.ps1"          
#> [21] "              13 File(s)         91,687 bytes"                                
#> [22] "               2 Dir(s)  31,422,464,000 bytes free"
print(system("dir"))
#> Warning in system("dir"): 'dir' not found
#> [1] 127
print(system2("dir"))
#> Warning in system2("dir"): '"dir"' not found
#> [1] 127
```

How did this come up? Depending on how you have installed highlight, the
`system()` and `shell()` calls below might produce different results.
Specifically, the `system()` call is reported to fail here if highlight
was installed via scoop, which uses a shim-based method of putting
things it installs on the `PATH`. This may additionally have something
to do with Windows short paths (?).

``` r
system("highlight --version")
#> [1] 0
shell("highlight --version")
Sys.which("highlight")
#>                              highlight 
#> "C:\\PROGRA~1\\HIGHLI~1\\HIGHLI~2.EXE"
```

In any case, my current hypothesis is that I should invoke highlight via
`shell()` on Windows, to be more resilient to the different ways users
may have installed highlight.

Let’s prove I can invoke highlight in several ways by implementing
`reprex_rtf()` “by hand”. First, we render a reprex to the “r” venue and
explicitly write a local output file.

``` r
library(reprex)

reprex_r(sample(LETTERS, 5), outfile = here::here("internal/gamma"))
#> Non-interactive session, setting `html_preview = FALSE`.
#> Preparing reprex as .R file:
#>   * C:/Users/jenny/Desktop/reprex/internal/gamma_reprex.R
#> Rendering reprex...
#> Writing reprex file:
#>   * C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.R
```

The output of this `gamma_reprex_rendered.R` is the input for the next
step, which is to form RTF.

More objects and helpers we’ll use:

``` r
r_file <- here::here("internal/gamma_reprex_rendered.R")
rtf_file <- here::here("internal/gamma_reprex_rendered.rtf")
```

### `system()`

``` r
(cmd <- glue::glue("
   highlight -i {r_file} --out-format=rtf --no-trailing-nl --encoding=UTF-8 \\
   -o {rtf_file}"))
#> highlight -i C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.R --out-format=rtf --no-trailing-nl --encoding=UTF-8 -o C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.rtf

system(cmd)
#> [1] 0

readLines(rtf_file)
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier New;}}{\\colortbl;\\red224\\green234\\blue238;\\red00\\green00\\blue00;\\red191\\green03\\blue03;\\red176\\green126\\blue00;\\red131\\green129\\blue131;\\red131\\green129\\blue131;\\red255\\green00\\blue255;\\red00\\green130\\blue00;\\red129\\green129\\blue00;\\red85\\green85\\blue85;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red01\\green01\\blue129;}"
#> [2] "\\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs20"                                                                                                                                                                                                                                                                                                                                                                                                        
#> [3] "\\pard \\cbpat1{{\\cf2{}}{\\cf15{sample}}{\\cf2{}}{\\cf11{(}}{\\cf2{LETTERS}}{\\cf11{,}} {\\cf2{}}{\\cf4{{5}}}{\\cf2{}}{\\cf11{)}}}\\par\\pard"                                                                                                                                                                                                                                                                                                                                                        
#> [4] "\\cbpat1{{\\cf2{}}{\\cf5{\\i #> [{1}] \"Q\" \"Z\" \"T\" \"R\" \"B\"\\i0 }}{\\cf2{}}}}"
```

### `system2()`

``` r
unlink(rtf_file)

(args <- c(
  glue::glue("-i {r_file}"),
  "--out-format=rtf", "--no-trailing-nl", "--encoding=UTF-8",
  glue::glue("-o {rtf_file}")
))
#> [1] "-i C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.R"  
#> [2] "--out-format=rtf"                                                   
#> [3] "--no-trailing-nl"                                                   
#> [4] "--encoding=UTF-8"                                                   
#> [5] "-o C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.rtf"

print(system2("highlight", args))
#> [1] 0

readLines(rtf_file)
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier New;}}{\\colortbl;\\red224\\green234\\blue238;\\red00\\green00\\blue00;\\red191\\green03\\blue03;\\red176\\green126\\blue00;\\red131\\green129\\blue131;\\red131\\green129\\blue131;\\red255\\green00\\blue255;\\red00\\green130\\blue00;\\red129\\green129\\blue00;\\red85\\green85\\blue85;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red01\\green01\\blue129;}"
#> [2] "\\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs20"                                                                                                                                                                                                                                                                                                                                                                                                        
#> [3] "\\pard \\cbpat1{{\\cf2{}}{\\cf15{sample}}{\\cf2{}}{\\cf11{(}}{\\cf2{LETTERS}}{\\cf11{,}} {\\cf2{}}{\\cf4{{5}}}{\\cf2{}}{\\cf11{)}}}\\par\\pard"                                                                                                                                                                                                                                                                                                                                                        
#> [4] "\\cbpat1{{\\cf2{}}{\\cf5{\\i #> [{1}] \"Q\" \"Z\" \"T\" \"R\" \"B\"\\i0 }}{\\cf2{}}}}"
```

### `shell()`

``` r
unlink(rtf_file)

(cmd <- glue::glue("
   highlight -i {r_file} --out-format=rtf --no-trailing-nl --encoding=UTF-8 \\
   -o {rtf_file}"))
#> highlight -i C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.R --out-format=rtf --no-trailing-nl --encoding=UTF-8 -o C:/Users/jenny/Desktop/reprex/internal/gamma_reprex_rendered.rtf

print(shell(cmd))
#> [1] 0

readLines(rtf_file)
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier New;}}{\\colortbl;\\red224\\green234\\blue238;\\red00\\green00\\blue00;\\red191\\green03\\blue03;\\red176\\green126\\blue00;\\red131\\green129\\blue131;\\red131\\green129\\blue131;\\red255\\green00\\blue255;\\red00\\green130\\blue00;\\red129\\green129\\blue00;\\red85\\green85\\blue85;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red01\\green01\\blue129;}"
#> [2] "\\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs20"                                                                                                                                                                                                                                                                                                                                                                                                        
#> [3] "\\pard \\cbpat1{{\\cf2{}}{\\cf15{sample}}{\\cf2{}}{\\cf11{(}}{\\cf2{LETTERS}}{\\cf11{,}} {\\cf2{}}{\\cf4{{5}}}{\\cf2{}}{\\cf11{)}}}\\par\\pard"                                                                                                                                                                                                                                                                                                                                                        
#> [4] "\\cbpat1{{\\cf2{}}{\\cf5{\\i #> [{1}] \"Q\" \"Z\" \"T\" \"R\" \"B\"\\i0 }}{\\cf2{}}}}"

unlink(rtf_file)

print(shell(cmd, shell = "cmd"))
#> [1] 0

readLines(rtf_file)
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier New;}}{\\colortbl;\\red224\\green234\\blue238;\\red00\\green00\\blue00;\\red191\\green03\\blue03;\\red176\\green126\\blue00;\\red131\\green129\\blue131;\\red131\\green129\\blue131;\\red255\\green00\\blue255;\\red00\\green130\\blue00;\\red129\\green129\\blue00;\\red85\\green85\\blue85;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red01\\green01\\blue129;}"
#> [2] "\\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs20"                                                                                                                                                                                                                                                                                                                                                                                                        
#> [3] "\\pard \\cbpat1{{\\cf2{}}{\\cf15{sample}}{\\cf2{}}{\\cf11{(}}{\\cf2{LETTERS}}{\\cf11{,}} {\\cf2{}}{\\cf4{{5}}}{\\cf2{}}{\\cf11{)}}}\\par\\pard"                                                                                                                                                                                                                                                                                                                                                        
#> [4] "\\cbpat1{{\\cf2{}}{\\cf5{\\i #> [{1}] \"Q\" \"Z\" \"T\" \"R\" \"B\"\\i0 }}{\\cf2{}}}}"

unlink(rtf_file)

print(shell(cmd, shell = "powershell"))
#> [1] 0

readLines(rtf_file)
#> [1] "{\\rtf1\\ansi \\deff1{\\fonttbl{\\f1\\fmodern\\fprq1\\fcharset0 Courier New;}}{\\colortbl;\\red224\\green234\\blue238;\\red00\\green00\\blue00;\\red191\\green03\\blue03;\\red176\\green126\\blue00;\\red131\\green129\\blue131;\\red131\\green129\\blue131;\\red255\\green00\\blue255;\\red00\\green130\\blue00;\\red129\\green129\\blue00;\\red85\\green85\\blue85;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red00\\green00\\blue00;\\red00\\green87\\blue174;\\red01\\green01\\blue129;}"
#> [2] "\\paperw11905\\paperh16837\\margl1134\\margr1134\\margt1134\\margb1134\\sectd\\plain\\f1\\fs20"                                                                                                                                                                                                                                                                                                                                                                                                        
#> [3] "\\pard \\cbpat1{{\\cf2{}}{\\cf15{sample}}{\\cf2{}}{\\cf11{(}}{\\cf2{LETTERS}}{\\cf11{,}} {\\cf2{}}{\\cf4{{5}}}{\\cf2{}}{\\cf11{)}}}\\par\\pard"                                                                                                                                                                                                                                                                                                                                                        
#> [4] "\\cbpat1{{\\cf2{}}{\\cf5{\\i #> [{1}] \"Q\" \"Z\" \"T\" \"R\" \"B\"\\i0 }}{\\cf2{}}}}"
```

### Clean up

``` r
unlink(list.files(here::here("internal"), pattern = "gamma_reprex", full.names = TRUE))
```
