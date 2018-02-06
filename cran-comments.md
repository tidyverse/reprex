This is an update of a package recently declared ORPHANED by CRAN.

With this release, reprex no longer accesses the clipboard on CRAN, neither for examples nor tests.

I've also made sure reprex tests that exercise Pandoc don't run if Pandoc is not present, which seems to be the cause of persistent errors for reprex on CRAN's OS X machines. To be clear, Pandoc is listed in SystemRequirements, going back to the previous release in January 2017.

## Test environments

* local OS X install, R 3.4.3
* Ubuntu 14.04.5 LTS (trusty) via travis-ci, R 3.1 through R-devel
* Windows Server 2012 R2 x64 (build 9600), R 3.4.3 via appveyor
* Windows, R Under development (unstable) (2018-02-01 r74194) via win-builder

## R CMD check results
  		  
0 errors | 0 warnings | 1 note

The note is about the fact that reprex is currently ORPHANED, so this is nominally a change of Maintainer.

The only reverse dependency is the tidyverse package, which passes R CMD check cleanly with this version of reprex.
