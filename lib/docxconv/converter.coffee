fs = require 'fs'
path = require 'path'
childProcess = require 'child_process'

unoconv = require 'unoconv'
listener = unoconv.listen({ port: 2002 })

pandoc = require 'pdc'

tidy = require('htmltidy').tidy
cheerio = require 'cheerio'
defaultOpts = require('./options')
msg = require './msg'

converter = exports = module.exports = {}

converter.html = (file, destination, opts, callback) ->
  # Fallback to default opts
  opts ?= defaultOpts

  unoconv.convert file, 'html', (err, result) ->
    # Pre DOM cleanup
    msg.log "info", "[$] Pre DOM cleanup of %s", file

    $ = cheerio.load(result)
    $('[lang^="en-"]').removeAttr('lang')
    $('col', 'table').remove()

    tidy $.html(), opts.tidy, (err, html) ->
      return callback(err) if err

      msg.log "done", "[*] conversion and tidy of %s complete", file

      # Post DOM cleanup
      msg.log "info", "[$] Post DOM cleanup of %s", file
      html = html.replace(/&nbsp;/g, ' ')
        .replace(/\b(\w+?)<span>(\w+?)<\/span>(\w+?)\b/ig, "$1$2$3")
        .replace(/\s*?<p([^>].+?)>\s*(?:\s*?<br>\s*?){1,}<\/p>\n?/mg, "")

      $ = cheerio.load(html)
      $('*:empty').remove()

      htmlFile = outputFileName(file, '.html', destination)
      htmlContent = $.html()

      try
        msg.log "warn", "[>] Writing html %s", htmlFile
        fs.writeFileSync htmlFile, htmlContent
      catch error
        msg.log "error", "[!] Error writing file: %s", error
        return callback(error)
      finally
        htmlResult = {
          file: htmlFile,
          content: htmlContent
        }
        callback(null, htmlResult)

converter.markdown = (html, destination, opts, callback) ->
  # Fallback to default opts
  opts ?= defaultOpts

  md = 'markdown+fancy_lists+startnum+superscript+subscript+implicit_figures'

  pandoc html.content, 'html', md, opts.pandoc, (err, result) ->
    return callback(err) if err

    file = outputFileName(html.file, '.md', destination)

    msg.log "info", "[$] Post conversion cleanup of %s", file
    result = result.replace(/​/g, '').replace(/\\\s*\n/g, '')
    $ = cheerio.load(result)
    $('*:empty').remove()

    try
      msg.log "warn", "[>] Writing markdown %s", file
      fs.writeFileSync file, result
    catch error
      msg.log "error", "[!] Error writing file: %s", error
      return callback(error)
    finally
      callback(null, result)

outputFileName = (file, extension, destination) ->
  ext = path.extname file
  basename = path.basename file, ext
  return path.join destination + path.sep + basename + extension
