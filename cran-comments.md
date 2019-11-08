This submission updates two test expectations to reflect changes in the dependency fs (version 1.3.1).

## Test environments
* local OS X install, R 3.5.3
* ubuntu 14.04 (on travis-ci), R devel through 3.2
* win-builder (devel and release)
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit (r-hub)
* Windows Server 2012 R2 x64 (build 9600), R 3.6.0 (appveyor)

## R CMD check results

0 errors | 0 warnings | 0 notes

The reverse dependency, tidyverse, passes R CMD check cleanly with this version of reprex.

