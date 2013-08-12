async = require 'async'

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

    if @format is 'html' or @format is 'markdown'
      converter.html file, @output, @opts, (err, result) =>
        return callback(err) if err

        if @format is 'markdown'
          msg.log "info", "[~] Converting html -> markdown %s", file
          converter.markdown result, @output, @opts, (err, md) ->
            return callback(err) if err

            callback(null)
        else
          callback(null)

    else
      msg.log "warn", "[!] Don't know how to convert to %s.", @format
      callback(null)

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
