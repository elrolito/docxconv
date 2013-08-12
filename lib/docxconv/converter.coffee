childProcess = require 'child_process'

unoconv = require 'unoconv'
listener = unoconv.listen({ port: 2002 })

tidy = require('htmltidy').tidy
cheerio = require 'cheerio'
defaultOpts = require('./options')

convert2html = (file, opts, callback) ->
  # Fallback to default opts
  opts ?= defaultOpts

  unoconv.convert file, 'html', (err, result) ->
    # Pre DOM cleanup
    console.log "[$] Pre DOM cleanup."

    $ = cheerio.load(result)
    $('[lang^="en-"]').removeAttr('lang')
    $('col', 'table').remove()

    tidy $.html(), opts.tidy, (err, html) ->
      return callback(err) if err

      console.log("[*] html conversion and tidy complete")

      # Post DOM cleanup
      console.log "[$] Post DOM cleanup."
      html = html.replace(/&nbsp;/g, ' ')
      $ = cheerio.load(html)
      $('p:empty').remove()

      callback(null, $.html())

exports.html = convert2html
