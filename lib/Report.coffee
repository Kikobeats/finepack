'use strict'

Logger  = require 'acho'
chalk   = require 'chalk'
keys    = require './Keywords'
DEFAULT = require './Default'

module.exports = class Report

  constructor: (@filename='Your file', @isColorizable=false) ->
    @logger = new Logger @isColorizable

  validate: (file) ->
    required : @_validateRequiredFields file
    missing  : @_validateMissingFields file

  resume: (file, options) ->
    validate: if options.validate then @validate file else DEFAULT.validate

  successMessage: (cb, data) ->
    message = "#{@filename} is now fine."
    message = @_corolizeMessage message if @isColorizable
    @logger.push 'success', message
    cb null, data, @logger.messages

  requiredMessage: (cb, data) ->
    message = "#{@filename} isn't fine. Check the file and run again."
    message = @_corolizeMessage message if @isColorizable
    @logger.push 'info', message
    cb true, data, @logger.messages

  missingMessage: (cb, data) ->
    message = "#{@filename} is almost fine. Check the file and run again."
    message = @_corolizeMessage message if @isColorizable
    @logger.push 'info', message
    cb true, data, @logger.messages

  alreadyMessage: (cb, data) ->
    message = "#{@filename} is already fine."
    message = @_corolizeMessage message if @isColorizable
    @logger.push 'info', message
    cb null, data, @logger.messages

  _corolizeMessage: (message) ->
    message = message.replace @filename, chalk.bold @filename
    message = message.replace 'fine', chalk.bold 'fine'
    message

  _validateRequiredFields : (file) ->
    haveRequiredValues = false
    for key in keys.required when not file[key]?
      @logger.push 'error', "required '#{key}'."
      haveRequiredValues = true unless haveRequiredValues
    haveRequiredValues

  _validateMissingFields : (file) ->
    haveMissingValues = false
    for key in keys.missing when not file[key]?
      @logger.push 'warning', "missing '#{key}'."
      haveMissingValues = true unless haveMissingValues
    haveMissingValues
