This is an update of a package declared ORPHANED by CRAN in January.

reprex is intended for interactive use and the clipboard has always been the user's primary means of providing input (a short piece of code) and the primary means of returning output (the rendered code). The package's use of the clipboard is now prominently documented in package Title, README, and at the top of the help for all relevant functions.

As I have explained in previous email correspondence, it would substantially reduce the usability of reprex to require that the user explicitly request `clipboard = TRUE` in each call to `reprex()`. I have sought advice on any alternative and, in the meantime, have done as much as I can via documentation.

Notes from several previous attempts update reprex ----------------------------

No example shows the act of writing to or reading from a file in the user's file space. It is always to a file below the session temp directory.

reprex no longer accesses the clipboard on CRAN: not via examples, tests, or the vignette (which I believe may have been what launched xsel in the previous re-submission).

The documentation for both reprex() and reprex_clean()/reprex_invert()/ reprex_rescue()) now states in the first sentence that the primary purpose of these functions is specifically to write to the user's clipboard. If a user does not want to use the clipboard features of reprex, then the user would use the rmarkdown or knitr package directly to render their code. I believe usage of reprex package and the reprex()/reprex_clean()/reprex_invert()/ reprex_rescue() functions implies that the user understands that reprex may read from or write to the clipboard.

reprex's handling of the clipboard is also consistent with several packages currently on CRAN, at least one of which was accepted since the recent addition of clipboard language to the CRAN Repository Policy. Like reprex, these packages and/or functions are clearly used with the purpose of reading/writing clipboard.

I've also made sure reprex tests that exercise Pandoc don't run if Pandoc is not present, which seems to be the cause of persistent errors for reprex on CRAN's OS X machines. To be clear, Pandoc is listed in SystemRequirements, going back to the previous release in January 2017.

## Test environments

* local OS X install, R 3.4.3
* Ubuntu 14.04.5 LTS (trusty) via travis-ci, R 3.1 through R-devel
* Windows Server 2012 R2 x64 (build 9600), R 3.5.0 via appveyor
* Windows, R Under development (unstable) (2018-02-01 r74194) via win-builder

## R CMD check results
  		  
0 errors | 0 warnings | 1 note

The note is about the fact that reprex is currently ORPHANED, so this is nominally a change of Maintainer.

The only reverse dependency is the tidyverse package, which passes R CMD check cleanly with this version of reprex.
