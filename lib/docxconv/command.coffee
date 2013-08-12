async = require 'async'
fs = require 'fs'
path = require 'path'

argv = require('optimist')
  .usage('Usage: $0 [-foc] <file>|<glob> ...')
  .alias('f', 'format')
  .default('f', 'html')
  .describe('f', 'conversion format')
  .alias('o', 'output')
  .demand('o')
  .describe('o', 'output destination')
  .alias('q', 'workers')
  .describe('q', 'queue worker concurrency')
  .default('q', 4)
  .describe('watch', 'directory to watch for added files')
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
            console.log msg.err("[!] There was an error during the conversion.")

  if argv.watch
    console.log msg.warn("[?] Watching %s for new files"), argv.watch
    watch.createMonitor argv.watch, (monitor) ->
      monitor.on 'created', (file, stat) ->
        console.log msg.info("[+] %s was added to watched directory."), file

        # Only watch for documents.
        if path.extname(file).match(/docx?/)
          docxconv.convert file, (err) ->
            console.log msg.done("[@] Finished converting added file %s"), file
        else
          console.log msg.err("[!] Cannot convert %s to html"), file

        console.log msg.info("[?] Still watching %s"), argv.watch
      monitor.on 'changed', (file, curr, prev) ->
        # Handle changed
      monitor.on 'removed', (file, stat) ->
        # Handle removed

exports.run = run
