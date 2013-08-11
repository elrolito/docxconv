async = require 'async'
fs = require 'fs'

argv = require('optimist')
  .usage('Usage: $0 [-foc] <file>|<glob> ...')
  .alias('f', 'format')
  .default('f', 'html')
  .describe('f', 'conversion format')
  .alias('o', 'output')
  .demand('o')
  .describe('o', 'output destination')
  .alias('w', 'workers')
  .describe('w', 'queue worker concurrency')
  .default('w', 4)
  .argv

docxconv = require('./docxconv')

run = () ->
  if argv._
    # Filter out files that exist and queue
    async.filter argv._, fs.exists, (results) ->
      if results.length > 0
        # Check if output directory exists
        unless fs.existsSync(argv.output)
          fs.mkdirSync(argv.output)

        docxconv.convert results, argv.f, argv.o, null, argv.w, (err) ->
          console.log "Done!"

exports.run = run
