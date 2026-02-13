# Suppress package startup messages

Sometimes your reprex uses packages that emit messages and warnings at
startup (dplyr is a very common culprit). In general, these are worth
reading! They can alert you to the root cause of your problem, such as a
function in one package masking a function in another. But in many
cases, this is just distracting, startup noise.

How can you silence this chatter, specifically? We don’t want to
suppress messages and warnings, in general, because they are an
important part of the reprex.

## TL;DR

Here’s a quick look at various techniques. They are described in more
detail below.

Call [`library()`](https://rdrr.io/r/base/library.html) with
`warn.conflicts = FALSE`.

``` r

library(dplyr, warn.conflicts = FALSE)
```

Surround a chatty [`library()`](https://rdrr.io/r/base/library.html)
call with
[`suppressPackageStartupMessages()`](https://rdrr.io/r/base/message.html).

``` r

suppressPackageStartupMessages(library(dplyr))
```

Break your reprex into “chunks”, in the `.Rmd` sense, and use a special
`#+` comment to silence messages and/or warnings for the chunk that
holds a chatty [`library()`](https://rdrr.io/r/base/library.html) call.
Note that the second `#+` comment is very important, so you don’t
silence messages and warnings for the entire reprex.

``` r

#+ message = FALSE, warning = FALSE
library(dplyr)

#+
slice(iris, 1)
```

If you’re using one or more tidyverse packages, consider using the
tidyverse metapackage, literally.
[`reprex::reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
has an argument `tidyverse_quiet`, which defaults to `TRUE` and silences
the startup messages.

``` r

library(tidyverse)

slice(iris, 1)
```

`tidyverse_quiet` also silences startup messages from the
[tidymodels](https://www.tidymodels.org) meta-package.

## dplyr is chatty at startup

dplyr is a common culprit for noisy startup, so we use it as an example.
Note this messaging as a baseline.

``` r

library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## `warn.conflicts = FALSE`

To suppress warnings about conflicts, set the `warn.conflicts` argument
of [`library()`](https://rdrr.io/r/base/library.html) to `FALSE`.

``` r

library(dplyr, warn.conflicts = FALSE)

slice(iris, 1)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
```

## `suppressPackageStartupMessages()`

Surround [`library()`](https://rdrr.io/r/base/library.html) with
[`suppressPackageStartupMessages()`](https://rdrr.io/r/base/message.html).

``` r

suppressPackageStartupMessages(library(dplyr))

slice(iris, 1)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
```

## Set `message = FALSE` and `warning = FALSE` for a chunk

If we were working in R Markdown, we could suppress messages and
warnings in the chunk containing
[`library()`](https://rdrr.io/r/base/library.html) calls, then put our
“real code” in a different chunk:

    ```{r, message = FALSE, warning = FALSE}  
    library(dplyr)  
    ```

    Some text.

    ```{r}     
    slice(iris, 1)
    ```

We can do the same in plain R code, suitable for
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)ing,
by using special comments that start with `#+`. Note that the second
`#+` is significant, because it begins a new chunk capable of emitting
messages and warnings.

``` r

#+ message = FALSE, warning = FALSE
library(dplyr)
message("You CANNOT hear me!")

#+ 
message("You can hear me!")
slice(iris, 1)
```

## reprex knows about `tidyverse_quiet`

The
[`reprex::reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md)
function has a `tidyverse_quiet` argument that defaults to `TRUE`. If
your reprex uses one or more tidyverse packages, consider attaching the
tidyverse metapackage, instead of individual packages, in order to enjoy
a quiet startup.

``` r

library(tidyverse) # instead of library(dplyr)

slice(iris, 1)
```

    #>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    #> 1          5.1         3.5          1.4         0.2  setosa

Note that this default behaviour can be overridden by setting
`tidyverse_quiet = FALSE` in a specific
[`reprex()`](https://reprex.tidyverse.org/dev/reference/reprex.md) call
or by setting the option `reprex.tidyverse_quiet = FALSE` in the
`.Rprofile` startup file. The `tidyverse_quiet` argument and
`reprex.tidyverse_quiet` option also affect startup messages from the
[tidymodels](https://www.tidymodels.org) meta-package.
