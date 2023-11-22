# stdout is captured

    Code
      (reprex(system2("echo", args = "blah"), std_out_err = TRUE))
    Output
       [1] "``` r"                                                                                   
       [2] "system2(\"echo\", args = \"blah\")"                                                      
       [3] "```"                                                                                     
       [4] ""                                                                                        
       [5] "<sup>Created on 2023-11-22 with [reprex v2.0.2.9000](https://reprex.tidyverse.org)</sup>"
       [6] ""                                                                                        
       [7] "<details style=\"margin-bottom:10px;\">"                                                 
       [8] "<summary>"                                                                               
       [9] "Standard output and standard error"                                                      
      [10] "</summary>"                                                                              
      [11] ""                                                                                        
      [12] "``` sh"                                                                                  
      [13] "blah"                                                                                    
      [14] "```"                                                                                     
      [15] ""                                                                                        
      [16] "</details>"                                                                              

