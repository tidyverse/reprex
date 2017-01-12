This package was just released on CRAN a couple of days ago.

## R CMD check results

The note is either about the fact that the last submission was only two days ago or that and the MIT license.

This is a small update in response to a message from Prof. Brian Ripley re: errors from examples and tests on Solaris:

https://cran.r-project.org/web/checks/check_results_reprex.html

These are all due to an undeclared system requirement.

I have now declared Pandoc as a system requirement in DESCRIPTION at the same version and in the same manner as the rmarkdown package, which the reprex package imports.
