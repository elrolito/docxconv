childProcess = require 'child_process'

unoconv = require 'unoconv'
listener = unoconv.listen({ port: 2002 })

tidy = require('htmltidy').tidy
opts = require('./options').tidy

convert2html = (file, callback) ->
  unoconv.convert file, 'html', (err, result) ->
    tidy result, opts, (err, html) ->
      console.log("html conversion and tidy complete")
      callback(err, html)

exports.html = convert2html
