childProcess = require 'child_process'

unoconv = require 'unoconv'
listener = unoconv.listen({ port: 2002 })

tidy = require('htmltidy').tidy
defaultOpts = require('./options')

convert2html = (file, opts, callback) ->
  # Fallback to default opts
  opts ?= defaultOpts

  unoconv.convert file, 'html', (err, result) ->
    tidy result, opts.tidy, (err, html) ->
      return callback(err) if err

      console.log("[*] html conversion and tidy complete")
      callback(null, html)

exports.html = convert2html
