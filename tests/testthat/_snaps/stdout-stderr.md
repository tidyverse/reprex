# stdout is captured

    Code
      (reprex(system2("echo", args = "blah"), std_out_err = TRUE, advertise = FALSE))
    Output
       [1] "``` r"                                  
       [2] "system2(\"echo\", args = \"blah\")"     
       [3] "```"                                    
       [4] ""                                       
       [5] "<details style=\"margin-bottom:10px;\">"
       [6] "<summary>"                              
       [7] "Standard output and standard error"     
       [8] "</summary>"                             
       [9] ""                                       
      [10] "``` sh"                                 
      [11] "blah"                                   
      [12] "```"                                    
      [13] ""                                       
      [14] "</details>"                             

