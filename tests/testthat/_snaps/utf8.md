# UTF-8 encoding, string input

    Code
      print(out_utf8[i_out])
    Output
      [1] "#> [1] \"À\" \"Ë\" \"Ð\""

---

    Code
      print(charToRaw(out_utf8[i_out]))
    Output
       [1] 23 3e 20 5b 31 5d 20 22 c3 80 22 20 22 c3 8b 22 20 22 c3 90 22

