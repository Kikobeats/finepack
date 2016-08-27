'use strict'

chalk    = require 'chalk'
jsonlint = require 'jsonlint'
Logger   = require './Logger'
KEYWORDS = require './Keywords'
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

  _validateRequiredKeys: (objt) ->
    haveRequiredValues = false

    for key in KEYWORDS.required when not objt[key]?
      @logger.push 'error', MSG.required(key)
      haveRequiredValues = true unless haveRequiredValues

    haveRequiredValues

  _validateMissingKeys: (objt) ->
    haveMissingValues = false

    for key in KEYWORDS.missing
      unless objt[key]?
        @logger.push 'warn', MSG.missing(key)
        haveMissingValues = true unless haveMissingValues
      else
        hasInvalidValue = @_validateMissingKeysValues(objt, key)
        if (hasInvalidValue)
          @logger.push 'error', hasInvalidValue
          haveMissingValues = true unless haveMissingValues

    haveMissingValues

  _validateMissingKeysValues: (objt, key) ->
    return false unless KEYWORDS.missingValues.indexOf(key) isnt -1
    switch key
      when 'keywords'
        MSG.invalidValue(key, 'is empty') if objt[key].length is 0
