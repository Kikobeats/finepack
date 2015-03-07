'use strict'

chalk = require 'chalk'

module.exports = class Logger

  @types: ['error', 'warning', 'success', 'info']

  constructor: ->
    @messages = []
    @messages[type] = [] for type in Logger.types

  add: (type, content) ->
    @messages[type].push content

  error: (msg) ->
    @add 'error', "#{chalk.red("error")}: #{chalk.gray(msg)}"

  warning: (msg) ->
    @add 'warning', "#{chalk.yellow("warning")}: #{chalk.gray(msg)}"

  success: (msg) ->
    @add 'success', "#{chalk.green("success")}: #{msg}"

  info: (msg) ->
    @add 'info', "#{chalk.gray("info")}: #{msg}"

  @print: (messages)->
    haveWarningOrErrorMessages =
      (messages['warning'].length isnt 0) or (messages['error'].length isnt 0)

    console.log()
    for type in Logger.types
      console.log() if haveWarningOrErrorMessages
      console.log message for message in messages[type]
