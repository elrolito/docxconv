docxconv
========

Utility script to convert MS Word doc(x) files to clean HTML/Markdown.

1. Filter out files that exist
2. Run conversion on each file in parallel
   a. unoconv conversion to html
   b. tidy up the html
   c. pandoc to markdown
