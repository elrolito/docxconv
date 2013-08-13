async = require 'async'
fs = require 'fs'
path = require 'path'
watch = require 'watch'

argv = require('optimist')
  .usage('''
    Usage: docxconv [-fq] -o <path> <file> ... [--watch] [--watch-path=<path>]
   ''')
  .alias('f', 'format')
  .default('f', 'html')
  .describe('f', 'conversion format <html|markdown>')
  .alias('o', 'output')
  .demand('o')
  .describe('o', 'output destination <path>')
  .alias('q', 'workers')
  .describe('q', 'queue worker concurrency <int>')
  .default('q', 4)
  .boolean('tidy')
  .describe('cleanup', 'Booleans: cleanup.tidy, cleanup.pandoc')
  .boolean('stdout')
  .boolean('watch')
  .describe('watch', 'watch for new documents')
  .describe('watch-path', '<path> to watch')
  .argv

if argv.watch and argv._
  argv['watch-path'] ?= path.dirname(argv._[0])

msg = require './msg'

DocxConv = require('./docxconv').DocxConv
docxconv = new DocxConv(argv)

run = () ->
  if argv._
    # Filter out files that exist and queue
    async.filter argv._, fs.exists, (results) ->
      if results.length > 0
        # Check if output directory exists
        unless fs.existsSync(argv.output)
          fs.mkdirSync(argv.output)

        docxconv.convert results, (err) ->
          msg.log "error", err if err

  else
    msg.log "warn", "[!] Nothing to convert."

  if argv.watch
    if fs.existsSync argv['watch-path']
      msg.log "warn", "[?] Watching %s for new files", argv['watch-path']
      watch.createMonitor argv['watch-path'], (monitor) ->
        monitor.on 'created', (file, stat) ->

          # Only watch for documents.
          if path.extname(file).match(/docx?/i)
            msg.log "info", "[+] #{file} was added to watched directory."
            docxconv.convert file, (err) ->
              msg.log "error", "[!] Cannot convert #{file} to html" if err

        monitor.on 'changed', (file, curr, prev) ->
          # Handle changed
        monitor.on 'removed', (file, stat) ->
          # Handle removed
    else
      msg.log "error", "[!] Cannot watch #{argv['watch-path']} (does not exist)"

exports.run = run
