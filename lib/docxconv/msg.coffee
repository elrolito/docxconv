clc = require 'cli-color'

msg = exports = module.exports = {}
msg.err = clc.red.bold
msg.warn = clc.yellow
msg.info = clc.cyan
msg.done = clc.green.bold
