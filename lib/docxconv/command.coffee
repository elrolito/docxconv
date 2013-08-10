async = require 'async'
fs = require 'fs'

argv = require('./options').argv

DocxConvClass = require('./docxconv').DocxConv

run = () ->
  if argv._
    # Filter out files that exist and queue
    async.filter argv._, fs.exists, (results) ->
      if results.length > 0
        # Check if output directory exists
        unless fs.existsSync(argv.output)
          fs.mkdirSync(argv.output)

        docxconv = new DocxConvClass argv
        worker = docxconv.queueWorker.bind(docxconv)

        async.each results, worker, (err) ->
          console.log "all conversions complete"

exports.run = run
