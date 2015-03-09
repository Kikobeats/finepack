'use strict'

chalk  = require 'chalk'
Logger = require './Logger'
keys   = require './Keywords'

module.exports = class Report

  constructor: (@filename='Your file') ->
    @logger = new Logger()

  @default:
    haveRequiredErrors: false, haveMissingErrors: false

  required : (file) ->
    haveRequiredValues = false
    for key in keys.required when not file[key]?
      @logger.error "required '#{key}'"
      haveRequiredValues = true unless haveRequiredValues
    haveRequiredValues

  missing : (file) ->
    haveMissingValues = false
    for key in keys.missing when not file[key]?
      @logger.warning "missing '#{key}'"
      haveMissingValues = true unless haveMissingValues
    haveMissingValues

  resume: (file) ->
    haveRequiredErrors : @required file
    haveMissingErrors  : @missing  file

  successMessage: (cb, data) ->
    @logger.success("#{chalk.bold(@filename)} is now #{chalk.bold("fine")}!")
    cb(null, data, @logger.messages)

  requiredMessage: (cb, data) ->
    @logger.info("#{chalk.bold(@filename)} isn't #{chalk.bold('fine')}. Check the file and run again.")
    cb(true, data, @logger.messages)

  missingMessage: (cb, data) ->
    @logger.info("#{chalk.bold(@filename)} is almost #{chalk.bold('fine')}. Check the file and run again.")
    cb(true, data, @logger.messages)

  alreadyMessage: (cb, data) ->
    @logger.info("#{chalk.bold(@filename)} is already #{chalk.bold("fine")}!")
    cb(null, data, @logger.messages)
