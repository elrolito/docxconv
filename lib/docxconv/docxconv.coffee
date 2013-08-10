async = require 'async'
fs = require 'fs'
path = require 'path'

converter = require './converter'

class DocxConv
  constructor: (@args) ->
    console.log "Docxconv init"
    @queue = async.queue @queueTask, @args.c
    @queue.drain = () ->
      console.log "All tasks completed."

  queueWorker: (task, callback) ->
    @queue.push task, (err) ->
      console.log "Adding %s to conversion queue", task

  queueTask: (task, callback) =>
    console.log "Executing task (%d at a time): %s", @args.c, task

    file = task

    if @args.f is 'html'
      converter.html file, (err, html) =>
        ext = path.extname file
        basename = path.basename file, ext
        output = path.join(@args.o + path.sep + basename + '.html')

        fs.writeFile output , html, (err) ->
          console.log "Writing %s", output
          callback(err)
    else
      console.log "No task for %s", @args.f
      callback()

exports.DocxConv = DocxConv
