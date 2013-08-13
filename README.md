docxconv
========

Utility script to convert MS Word doc(x) files to clean HTML, using DOM cleanup and HTML Tidy.

Usage
-----

```text
docxconv [-fq] -o <path> <file> ... [--watch] [--watch-path=<path>]
         [--tidy] [--cleanup.tidy] [--cleanup.pandoc] [--stdout]

Options:
  -f, --format   conversion format <html|markdown>       [default: "html"]
  -o, --output   output destination <path>               [required]
  -q, --workers  queue worker concurrency <int>          [default: 4]
  --cleanup      Booleans: cleanup.tidy, cleanup.pandoc
  --stdout       Do not write file, use stdout instead
  --watch        watch for new documents
  --watch-path   <path> to watch
```

Requirements
------------

See [unoconv](https://github.com/gfloyd/node-unoconv) requirements.

Known Issues
------------

Unoconv does not seem to currently work with LibreOffice version 4 and above. Haven’t tried with OpenOffice.

Tested and working with LibreOffice [v3.6.7](http://www.libreoffice.org/download/?&version=3.6.7&lang=en-US).
