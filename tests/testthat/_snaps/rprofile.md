# local .Rprofile reporting responds to venue

    Code
      rprofile_alert("gh")
    Output
      [1] "```{r, results = 'asis', echo = FALSE, include = file.exists('.Rprofile'), eval = file.exists('.Rprofile')}"
      [2] "cat(sprintf(\"*Local `.Rprofile` detected at `%s`*\", normalizePath(\".Rprofile\")))"                       
      [3] "```"                                                                                                        

---

    Code
      rprofile_alert("r")
    Output
      [1] "```{r, results = 'asis', echo = FALSE, include = file.exists('.Rprofile'), eval = file.exists('.Rprofile')}"
      [2] "cat(sprintf(\"Local .Rprofile detected at %s\", normalizePath(\".Rprofile\")))"                             
      [3] "```"                                                                                                        

