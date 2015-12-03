'use strict'

Acho     = require 'acho'
chalk    = require 'chalk'
jsonlint = require 'jsonlint'
DEFAULT  = require './Default'
keys     = require './Keywords'

module.exports = class Report

  constructor: (@name = 'Your file', @isColorizable = false, @isValidationEnable = false) ->
    @logger = Acho color: @isColorizable

  lint: (objt) ->
    objt = JSON.stringify(objt) if typeof objt isnt 'string'
    jsonlint.parse objt

  validate: (objt, isValidationEnable) ->
    return DEFAULT.validate unless @isValidationEnable
    required : @_validateRequiredKeys objt
    missing  : @_validateMissingKeys objt

  errorMessage: (cb, data) ->
    message = @_messageBuilder "Something in #{@name} is wrong. See below."
    @logger.push 'error', message
    cb true, data, @logger.messages

  successMessage: (cb, data) ->
    message = @_messageBuilder "#{@name} is now fine."
    @logger.push 'success', message
    cb null, data, @logger.messages

  requiredMessage: (cb, data) ->
    message = @_messageBuilder "#{@name} isn't fine. Check the file and run again."
    @logger.push 'info', message
    cb null, data, @logger.messages

  missingMessage: (cb, data) ->
    message = @_messageBuilder "#{@name} is almost fine. Check the file and run again."
    @logger.push 'info', message
    cb null, data, @logger.messages

  alreadyMessage: (cb, data) ->
    message = @_messageBuilder "#{@name} is already fine."
    @logger.push 'info', message
    cb null, data, @logger.messages

  _messageBuilder: (message) ->
    return message unless @isColorizable
    message = message.replace @name, chalk.bold @name
    message = message.replace 'fine', chalk.bold 'fine'
    message

  _validateRequiredKeys : (objt) ->
    haveRequiredValues = false
    for key in keys.required when not objt[key]?
      @logger.push 'error', "required '#{key}'."
      haveRequiredValues = true unless haveRequiredValues
    haveRequiredValues

  _validateMissingKeys : (objt) ->
    haveMissingValues = false
    for key in keys.missing when not objt[key]?
      @logger.push 'warn', "missing '#{key}'."
      haveMissingValues = true unless haveMissingValues
    haveMissingValues
