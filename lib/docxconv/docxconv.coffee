async = require 'async'
fs = require 'fs'
path = require 'path'

converter = require './converter'
msg = require './msg'

class DocxConv
  constructor: (args, @opts) ->
    { @format, @output, @workers } = args

    # Create queue instance
    console.log msg.done("Creating queue with %d workers."), @workers
    @queue = async.queue @taskWorker, @workers
    @queue.drain = () ->
      console.log msg.done("[✓] All tasks completed.")
    @queue.empty = () ->
      console.log msg.done("[ ] Queue empty.")

  taskWorker: (file, callback) =>
    console.log "[~] Converting %s to %s", file, @format

    switch @format
      when 'html'
        converter.html file, @opts, (err, html) =>
          return callback(err) if err

          ext = path.extname file
          basename = path.basename file, ext
          result = path.join(@output + path.sep + basename + '.html')

          try
            console.log msg.warn("[>] Writing %s"), result
            fs.writeFileSync result, html
          catch error
            console.log msg.err("[!] Error writing file: %s"), error
            return callback(error)
          finally
            return callback()
      else
        console.log msg.warn("[!] Don't know how to convert to %s."), @format

  convert: (batch, callback) =>
    console.log msg.info("[+] Adding %s to queue."), batch

    # Add batch to queue to process
    @queue.push batch, (err) =>
      return callback(err) if err

      console.log msg.done("[*] Finished task.")

      taskCount = @queue.length()
      if taskCount > 0
        console.log msg.info("[#] %d left in queue."), @queue.length()

      callback(null, batch)

    console.log msg.warn("[#] %d files in queue."), @queue.length()

exports.DocxConv = DocxConv
