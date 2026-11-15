'use strict'

chalk = require 'chalk'

TYPES = ['debug', 'info', 'success', 'warn', 'error']

debug = require('debug-logfmt')('finepack', levels: TYPES.filter (type) -> type isnt 'debug')

FIGURES = if process.platform is 'win32'
  info: 'i', success: '√', warning: '‼', error: '×'
else
  info: 'ℹ', success: '✔', warning: '⚠', error: '✖'

STYLES =
  debug: symbol: FIGURES.info, paint: (palette) -> palette.hex '#33ccff'
  info: symbol: FIGURES.info, paint: (palette) -> palette.white
  success: symbol: FIGURES.success, paint: (palette) -> palette.hex '#33ff66'
  warn: symbol: FIGURES.warning, paint: (palette) -> palette.hex '#ffcc33'
  error: symbol: FIGURES.error, paint: (palette) -> palette.hex '#FF3333'

traceFor = (type) -> if type is 'debug' then debug else debug[type]

trace = (type, message) -> traceFor(type) String(message).replace(/%/g, '%%')

createMessages = ->
  TYPES.reduce ((messages, type) -> Object.assign messages, "#{type}": []), {}

paletteFor = (color) -> if color is false then new chalk.Instance(level: 0) else chalk

module.exports = class Logger
  constructor: ->
    @messages = createMessages()

  push: (type, message) ->
    trace type, message
    @messages[type].push message
    this

  @trace: trace

  @render: (messages = {}, {color} = {}) ->
    palette = paletteFor color
    text = if color is true then palette.gray else String
    lines = []
    for type in TYPES
      {symbol, paint} = STYLES[type]
      for message in messages[type] ? []
        lines.push "#{paint(palette)(symbol)} #{text message}"
    lines
