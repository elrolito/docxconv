async = require 'async'
fs = require 'fs'
path = require 'path'

converter = require './converter'
msg = require './msg'

class DocxConv
  constructor: (args, @opts) ->
    { @format, @output, @workers, @tidy, @cleanup, @stdout, @watch } = args

    @errors = []

    # Create queue instance
    console.log "Creating queue with #{@workers} workers."
    @queue = async.queue @taskWorker, @workers

    @queue.drain = () =>
      msg.log "done", "[✓] All tasks completed."

      errorCount = @errors.length

      if errorCount > 0
        msg.log "error", "[!] #{errorCount} files not converted:"
        msg.log "error", "#{error.error}: #{error.file}" for error in @errors
        msg.log "warn", "[@] Trying again..."
        for error in @errors
          do (error) =>
            @convert error.file, (err)->
              if err
                msg.log "error", "[!] Still can’t convert #{error.file}"

      if @watch
        console.log "Still watching #{args['watch-dir']} for new files..."

    @queue.saturated = () ->
      msg.log "warn", "[#] Queue saturated, #{@length()} tasks pending."

    @queue.empty = () ->
      msg.log "warn", "[ ] Queue empty."

  taskWorker: (file, callback) =>
    unless @format.match(/html|markdown/i)
      msg.log "warn", "[!] Don't know how to convert to #{@format}."
      return callback("Unknown format")

    ext = path.extname file
    basename = path.basename file, ext

    msg.log "info", "[-] Converting #{file} to #{ @format}, removed from queue."

    async.waterfall [
      # 1. Unoconv
      (callback) ->
        msg.log "info", "[1] doc(x)->html via unoconv: #{basename}"

        converter.unoconv file, (err, result) ->
          return callback(err) if err

          msg.log "done", "[1] HTML conversion done: #{basename}"
          callback(null, result)

      # 2. Tidy
      (html, callback) =>
        # Skip unless --tidy arg given
        unless @tidy
          msg.log "warn", "[2] Skipping Tidy: #{basename}"
          return callback(null, html)

        msg.log "info", "[2] Tidy HTML cleanup: #{basename}"

        converter.tidy html, @opts, (err, result) ->
          return callback(err) if err

          msg.log "done", "[2] Tidy done: #{basename}"
          callback(null, result)

      # 3. Post-Tidy DOM Cleanup
      (html, callback) =>
        # Skip unless --cleanup.tidy
        unless @cleanup and @cleanup.tidy
          msg.log "warn", "[3] Skipping post-Tidy cleanup: #{basename}"
          return callback(null, html)

        msg.log "info", "[3] Post-Tidy cleanup: #{basename}"

        converter.postcleanup html, (err, result) ->
          return callback(err) if err

          msg.log "done", "[3] Post-Tidy cleanup done: #{basename}"
          callback(null, result)

      # 4. Pandoc
      (html, callback) =>
        # Skip unless --format is markdown
        unless @format.match(/markdown/i)
          msg.log "warn", "[4] No further conversions: #{basename}"
          return callback(null, html)

        msg.log "done", "[4] html -> #{@format} via pandoc: #{basename}"
        converter.pandoc html, @format, @opts, (err, result) ->
          return callback(err) if err

          msg.log "done", "[4] Pandoc conversion done: #{basename}"
          callback(null, result)

      # 5. Final cleanup
      (html, callback) =>
        unless @cleanup and @cleanup.pandoc
          msg.log "warn", "[5] Skipping final cleanup: #{basename}"
          return callback(null, html)

        converter.finalize html, (err, result) ->
          return callback(err) if err

          msg.log "info", "[5] Final cleanup done: #{basename}"
          callback(null, result)

      # 6. Write file
      (html, callback) =>
        # Skip writing file if --stdout
        return callback(null, html) if @stdout

        destination = @output + path.sep + basename + '.' + @format

        msg.log "warn", "[>] Writing file: #{destination}"
        fs.writeFile destination, html, (err) ->
          if err
            msg.log "error", "[!] Error writing file #{destination}: #{error}"
            return callback(err)

          console.log html if @stdout
          callback(null, destination)

    ], (err, result) =>
      if err
        msg.log "error", "[!] There was an error converting #{file}"
        @errors.push({ error: err, file: file })

        return callback(err)

      msg.log "done", "[*] Finished tasks: #{file} -> #{result}"
      callback(null, result)

  convert: (batch, callback) =>
    @errors = []

    if Array.isArray(batch)
      batchSize = batch.length
    else
      batchSize = 1

    msg.log "info", "[+] Adding #{batchSize} tasks to queue."
    @queue.push batch, (err) =>
      return callback(err) if err

      taskCount = @queue.length()
      if taskCount > 0
        msg.log "info", "[#] #{@queue.length()} left in queue."

      callback(null, batch)

    msg.log "warn", "[#] #{@queue.length()} files in queue."

exports.DocxConv = DocxConv
