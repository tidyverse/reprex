# retrofit_files() works

    Code
      retrofit_files(wd = "this", outfile = "that")
    Message <cliMessage>
      ! `outfile` is deprecated, in favor of `wd`
    Output
      $infile
      NULL
      
      $wd
      [1] "this"
      

---

    Code
      retrofit_files(outfile = NA)
    Message <cliMessage>
      ! `outfile` is deprecated, in favor of `wd`
      ! Use `reprex(wd = ".")` instead of `reprex(outfile = NA)`
    Output
      $infile
      NULL
      
      $wd
      [1] "."
      

---

    Code
      retrofit_files(outfile = "some/path/blah")
    Message <cliMessage>
      ! `outfile` is deprecated
      ! To control output filename, provide a filepath to `input`
      ! Only taking working directory from `outfile`
    Output
      $infile
      NULL
      
      $wd
      [1] "some/path"
      

---

    Code
      retrofit_files(infile = "a/path/foo.R", outfile = NA)
    Message <cliMessage>
      ! `outfile` is deprecated, working directory will be derived from `input`
    Output
      $infile
      [1] "a/path/foo.R"
      
      $wd
      NULL
      

---

    Code
      retrofit_files(infile = "a/path/foo.R", outfile = "other/path/blah")
    Message <cliMessage>
      ! `outfile` is deprecated
      ! Working directory and output filename will be determined from `input`
    Output
      $infile
      [1] "a/path/foo.R"
      
      $wd
      NULL
      

