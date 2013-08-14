unoconv = require 'unoconv'
listener = unoconv.listen({ port: 2002 })

pandoc = require 'pdc'
tidy = require('htmltidy').tidy
cheerio = require 'cheerio'

defaultOpts = require('./options')
msg = require './msg'

converter = exports = module.exports = {}

converter.unoconv = (file, callback) ->
  return callback("[!] Unoconv: file is empty") if isEmpty(file)

  unoconv.convert file, 'html', (err, result) ->
    return callback(err) if err

    callback(null, result)

converter.tidy = (html, opts, callback) ->
  return callback("[!] Tidy: no HTML to tidy.") if isEmpty(html)

  try
    $ = cheerio.load(html)
    $('[lang^="en-"]').removeAttr('lang')
    $('col', 'table').remove()
  catch error
    return callback(error)
  finally
    opts ?= defaultOpts
    tidy $.html(), opts.tidy, (err, result) ->
      return callback(err) if err

      callback(null, result)

converter.postcleanup = (html, callback) ->
  return callback("[!] Post-cleanup: no HTML to cleanup.") if isEmpty(html)

  try
    html = html.toString().replace(/&nbsp;/g, ' ')
      .replace(/\b(\w+)<span(?:.+?)>([^<>].+?)<\/span>([^\b].+?)?/gmi, "$1$2$3")
      .replace(/\s*?<p([^>].+?)>\s*(?:\s*?<br>\s*?){1,}<\/p>\n?/mg, "")
      .replace(/<span>([\u2000-\u200F}])<\/span>/gm, "$1")

    $ = cheerio.load(html)
    $('*:empty').remove()

    result = $.html()
  catch error
    return callback(error)
  finally
    callback(null, result)

converter.pandoc = (html, format, opts, callback) ->
  if isEmpty(html)
    return callback("[!] Pandoc: no HTML to convert to #{format}")

  if format.match(/markdown/i)
    format = 'markdown+fancy_lists+startnum'
    format += '+superscript+subscript+implicit_figures'

  opts ?= defaultOpts

  pandoc html, 'html', format, opts.pandoc, (err, result) ->
    return callback(err) if err

    callback(null, result)

converter.finalize = (html, callback) ->
  return callback("[!] Final cleanup: no HTML to cleanup.") if isEmpty(html)

  try
    html = html.toString().replace(/\\\s*\n/g, '')
      .replace(/​|\x{E2808B}| /g, '')

    $ = cheerio.load(html)
    $('*:empty').remove()
    result = $.html()
  catch error
    return callback(error)
  finally
    callback(null, result)

isEmpty = (stream) ->
  return stream.length < 1
