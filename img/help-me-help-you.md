The Jerry Maguire "help me help you" gif is from here:

<https://nypdecider.files.wordpress.com/2014/08/help-me-help-you.gif>

Save a local copy.

*(Have ImageMagick installed.)*

Split the gif into the stills:

```
convert help-me-help-you.gif help-me-help-you.png
```

Copy the best still:

```
cp help-me-help-you-15.png help-me-help-you-still.png
```

Make it smaller:

```
convert -resize 500 -colors 2048 -depth 16 -quality 95 help-me-help-you-still.png help-me-help-you-still-500-c256.png
```

Put the still in README.Rmd as a link to the gif (too obnoxious to have that thing looping on README.md):

```
<a href="https://nypdecider.files.wordpress.com/2014/08/help-me-help-you.gif"> <img src="internal/help-me-help-you-still-500-c256.png" width="300" height="100" align="right">
```


