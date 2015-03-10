'use strict'

chalk = require 'chalk'

module.exports = class Logger

  constructor: (@isColorizable = false) ->
    @messages = {}
    @messages[type] = [] for type in Logger.types

  add: (type, message) ->
    messageType = @_messageTypeBuilder type
    message = @_messageBuilder message
    @messages[type].push "#{messageType}: #{message}"

  @types: ['error', 'warning', 'success', 'info']

  @colorType: error: 'red', warning: 'yellow', success: 'green', info: 'white'

  @print: (messages)->
    isFinalMessage = false

    isWarningOrErrorMessage =
      (messages['warning'].length isnt 0) or (messages['error'].length isnt 0)

    isSuccessOrInfoMessage = (type) ->
      return false if isFinalMessage
      isFinalMessage = true if (type is 'success') or (type is 'info')

    console.log() if isWarningOrErrorMessage

    for type in Logger.types
      console.log() if isSuccessOrInfoMessage(type)
      console.log message for message in messages[type]

  _messageBuilder: (message) ->
    message = chalk.gray message if @isColorizable
    message

  _messageTypeBuilder: (messageType) ->
    if @isColorizable
      color = Logger.colorType[messageType]
      return chalk[color](messageType)
    messageType
