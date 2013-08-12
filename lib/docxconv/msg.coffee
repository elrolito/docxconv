clc = require 'cli-color'

msg = exports = module.exports = {}

msg.err = clc.red.bold
msg.warn = clc.yellow
msg.info = clc.cyan
msg.done = clc.green.bold

msg.log = (type, message, args...) ->
  switch type
    when 'err' then color = msg.err
    when 'warn' then color = msg.warn
    when 'info' then color = msg.info
    when 'done' then color = msg.done

  if args.length > 0
    return console.log color(message), args
  else
    return console.log color(message)
