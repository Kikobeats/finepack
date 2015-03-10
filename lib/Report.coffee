'use strict'

chalk  = require 'chalk'
Logger = require './Logger'
keys   = require './Keywords'

module.exports = class Report

  constructor: (@filename='Your file', @isColorizable=false) ->
    @logger = new Logger @isColorizable

  @default:
    haveRequiredErrors: false, haveMissingErrors: false

  required : (file) ->
    haveRequiredValues = false
    for key in keys.required when not file[key]?
      @logger.add 'error', "required '#{key}'"
      haveRequiredValues = true unless haveRequiredValues
    haveRequiredValues

  missing : (file) ->
    haveMissingValues = false
    for key in keys.missing when not file[key]?
      @logger.add 'warning', "missing '#{key}'"
      haveMissingValues = true unless haveMissingValues
    haveMissingValues

  resume: (file) ->
    haveRequiredErrors : @required file
    haveMissingErrors  : @missing  file

  successMessage: (cb, data) ->
    message = "#{@filename} is now fine"
    message = @_corolizeMessage message if @isColorizable
    @logger.add 'success', message
    cb(null, data, @logger.messages)

  requiredMessage: (cb, data) ->
    message = "#{@filename} isn't fine. Check the file and run again."
    message = @_corolizeMessage message if @isColorizable
    @logger.add 'info', message
    cb(true, data, @logger.messages)

  missingMessage: (cb, data) ->
    message = "#{@filename} is almost fine. Check the file and run again."
    message = @_corolizeMessage message if @isColorizable
    @logger.add 'info', message
    cb(true, data, @logger.messages)

  alreadyMessage: (cb, data) ->
    message = "#{@filename} is already fine"
    message = @_corolizeMessage message if @isColorizable
    @logger.add 'info', message
    cb(null, data, @logger.messages)

  _corolizeMessage: (message) ->
    message = message.replace @filename, chalk.bold(@filename)
    message = message.replace 'fine', chalk.bold('fine')
    message
