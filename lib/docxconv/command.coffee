async = require 'async'
fs = require 'fs'
path = require 'path'

argv = require('optimist')
  .usage('Usage: docxconv [-fq] -o <path> <file>|<path> [--watch]')
  .alias('f', 'format')
  .default('f', 'html')
  .describe('f', 'conversion format')
  .alias('o', 'output')
  .demand('o')
  .describe('o', 'output destination <path>')
  .alias('q', 'workers')
  .describe('q', 'queue worker concurrency <int>')
  .default('q', 4)
  .describe('watch', 'watch for new documents')
  .argv

msg = require './msg'

DocxConv = require('./docxconv').DocxConv
docxconv = new DocxConv(argv)

watch = require 'watch'

run = () ->
  if argv._
    # Filter out files that exist and queue
    async.filter argv._, fs.exists, (results) ->
      if results.length > 0
        # Check if output directory exists
        unless fs.existsSync(argv.output)
          fs.mkdirSync(argv.output)

        docxconv.convert results, (err) ->
          if err
            msg.log "err", "[!] There was an error during the conversion."

  if argv.watch
    msg.log "warn", "[?] Watching %s for new files", argv.watch
    watch.createMonitor argv.watch, (monitor) ->
      monitor.on 'created', (file, stat) ->
        msg.log "info", "[+] %s was added to watched directory.", file

        # Only watch for documents.
        if path.extname(file).match(/docx?/)
          docxconv.convert file, (err) ->
            msg.log "done", "[@] Finished converting added file %s", file
        else
          msg.log "err", "[!] Cannot convert %s to html", file

        msg.log "info", "[?] Still watching %s", argv.watch
      monitor.on 'changed', (file, curr, prev) ->
        # Handle changed
      monitor.on 'removed', (file, stat) ->
        # Handle removed

exports.run = run
