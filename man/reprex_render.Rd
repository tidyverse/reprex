% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reprex_render.R
\name{reprex_render}
\alias{reprex_render}
\title{Render a document in a new R session}
\usage{
reprex_render(input, html_preview = NULL, encoding = "UTF-8")
}
\arguments{
\item{input}{The input file to be rendered. This can be a \code{.R} script or a
\code{.Rmd} R Markdown document.}

\item{html_preview}{Logical. Whether to show rendered output in a viewer
(RStudio or browser). Always \code{FALSE} in a noninteractive session. Read more
about \code{\link[=opt]{opt()}}.}

\item{encoding}{The encoding of the input file. Note that the only acceptable
value is "UTF-8", which is required by knitr as of v1.24. This is exposed
as an argument purely for technical convenience, relating to the "Knit"
button in the RStudio IDE.}
}
\value{
The output of \code{\link[rmarkdown:render]{rmarkdown::render()}} is passed through, i.e. the path
of the output file.
}
\description{
This is a wrapper around \code{\link[rmarkdown:render]{rmarkdown::render()}} that enforces the "reprex"
mentality. Here's a simplified version of what happens:

\if{html}{\out{<div class="sourceCode">}}\preformatted{callr::r(
  function(input) \{
    rmarkdown::render(input, envir = globalenv(), encoding = "UTF-8")
  \},
  args = list(input = input),
  spinner = is_interactive(),
  stdout = std_file, stderr = std_file
)
}\if{html}{\out{</div>}}

Key features to note
\itemize{
\item \code{\link[rmarkdown:render]{rmarkdown::render()}} is executed in a new R session, by using
\code{\link[callr:r]{callr::r()}}. The goal is to eliminate the leakage of objects, attached
packages, and other aspects of session state from the current session into
the rendering session. Also, the system and user-level \code{.Rprofile}s are
ignored.
\item Code is evaluated in the \code{globalenv()} of this new R session, which means
that method dispatch works the way most people expect it to.
\item The input file is assumed to be UTF-8, which is a knitr requirement as of
v1.24.
\item If the YAML frontmatter includes \code{std_err_out: TRUE}, standard output and
error of the rendering R session are captured in \code{std_file}, which is
then injected into the rendered result.
}

\code{reprex_render()} is designed to work with the \code{\link[=reprex_document]{reprex_document()}} output
format, typically through a call to \code{\link[=reprex]{reprex()}}. \code{reprex_render()} may work
with other R Markdown output formats, but it is not well-tested.
}
\examples{
\dontrun{
reprex_render("input.Rmd")
}
}
