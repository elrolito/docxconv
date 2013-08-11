async = require 'async'
fs = require 'fs'
path = require 'path'

converter = require './converter'
docxconv = exports = module.exports = {}

docxconv.convert = (batch, format, output, opts, workers = 4, callback) ->
  console.log "Converting: %s", batch

  if format is 'html'
    console.log "...to html."
    worker = (file, callback) ->
      console.log "[~] Converting %s", file
      converter.html file, opts, (err, html) ->
        return callback(err) if err

        ext = path.extname file
        basename = path.basename file, ext
        result = path.join(output + path.sep + basename + '.html')

        fs.writeFile result, html, (err) ->
          return callback(err) if err

          console.log "[>] Writing %s", result
          callback()
  else
    console.log "[!] Don't yet know how to convert to %s.", format
    return callback()

  queue = async.queue worker, workers
  queue.drain = () ->
    console.log "[✓] All tasks completed."
  queue.empty = () ->
    console.log "[ ] Queue empty."

  console.log "[+] Adding %s to queue.", batch
  queue.push batch, (err) ->
    console.log "[-] Finished task, %d left in queue.", queue.length()

  console.log "[#] %d files in queue.", queue.length()
