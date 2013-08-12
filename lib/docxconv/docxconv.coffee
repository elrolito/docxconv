async = require 'async'
fs = require 'fs'
path = require 'path'

converter = require './converter'
msg = require './msg'

class DocxConv
  constructor: (args, @opts) ->
    { @format, @output, @workers } = args

    # Create queue instance
    msg.log "done", "Creating queue with %d workers.", @workers
    @queue = async.queue @taskWorker, @workers
    @queue.drain = () ->
      msg.log "done", "[✓] All tasks completed."
    @queue.saturated = () ->
      msg.log "warn", "[#] Queue saturated, tasks pending."
    @queue.empty = () ->
      msg.log "warn", "[ ] Queue empty."

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
            msg.log "warn", "[>] Writing %s", result
            fs.writeFileSync result, html
          catch error
            msg.log "err", "[!] Error writing file: %s", error
            return callback(error)
          finally
            return callback()
      else
        msg.log "warn", "[!] Don't know how to convert to %s.", @format

  convert: (batch, callback) =>
    msg.log "info", "[+] Adding %s to queue.", batch

    # Add batch to queue to process
    @queue.push batch, (err) =>
      return callback(err) if err

      msg.log "done", "[*] Finished task."

      taskCount = @queue.length()
      if taskCount > 0
        msg.log "info", "[#] %d left in queue.", @queue.length()

      callback(null, batch)

    msg.log "warn", "[#] %d files in queue.", @queue.length()

exports.DocxConv = DocxConv
