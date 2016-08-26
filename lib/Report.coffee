'use strict'

chalk    = require 'chalk'
jsonlint = require 'jsonlint'
Logger   = require './Logger'
keys     = require './Keywords'
MSG      = require './Messages'

DEFAULT =
  validate:
    required: false
    missing: false

module.exports = class Report

  constructor: (@name = 'Your file', @isColorizable = false, @isValidationEnable = false) ->
    @logger = Logger color: @isColorizable

  lint: (objt) ->
    objt = JSON.stringify(objt) if typeof objt isnt 'string'
    jsonlint.parse objt

  validate: (objt, isValidationEnable) ->
    return DEFAULT.validate unless @isValidationEnable
    required : @_validateRequiredKeys objt
    missing  : @_validateMissingKeys objt

  errorMessage: (cb, data) ->
    @logger.push 'error', MSG.wrong(@name)
    cb true, data, @logger.messages

  successMessage: (cb, data) ->
    @logger.push 'success', MSG.success(@name)
    cb null, data, @logger.messages

  requiredMessage: (cb, data) ->
    @logger.push 'info', MSG.notFine(@name)
    cb null, data, @logger.messages

  missingMessage: (cb, data) ->
    @logger.push 'info', MSG.almostFine(@name)
    cb null, data, @logger.messages

  alreadyMessage: (cb, data) ->
    @logger.push 'info', MSG.alreadyFine(@name)
    cb null, data, @logger.messages

  _validateRequiredKeys : (objt) ->
    haveRequiredValues = false
    for key in keys.required when not objt[key]?
      @logger.push 'error', MSG.required(@key)
      haveRequiredValues = true unless haveRequiredValues
    haveRequiredValues

  _validateMissingKeys : (objt) ->
    haveMissingValues = false
    for key in keys.missing when not objt[key]?
      @logger.push 'warn', MSG.missing(@key)
      haveMissingValues = true unless haveMissingValues
    haveMissingValues
