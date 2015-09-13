# reprex 0.1.0

# reprex 0.0.0.9001

  * Reprex code can be provided as an R expression. `reprex()` became a wrapper around new exported function `reprex_()`, that takes reprex code as character vector. (#6 @dgrtwo)

  * `reprex()` gains a `session_info` argument to request that `devtools::session_info()` or `sessionInfo()` be appended to reprex code. (#6 @dgrtwo)
  
  * `reprex()` gains a `upload.fun` argument to be passed as package option to `knitr`. Defaults to `knitr::imgur_upload`, which means figures produced by the reprex will be uploaded to [imgur.com](http://imgur.com) and the associated image syntax will be put into the Markdown, e.g. `![](http://i.imgur.com/2kgtD.png)`. (#15 @paternogbc)
  
  * `reprex()` now uses clipboard functionality from [`clipr`](https://github.com/mdlincoln/clipr) and thus should work on Windows and suitably prepared Linux systems, in addition to Mac OS. (#16 @mdlincoln)

# reprex 0.0.0.9000

  * I tweeted about this and some people actually used it!
