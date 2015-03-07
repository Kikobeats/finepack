'use strict'

path   = require 'path'
chalk  = require 'chalk'
Logger = require './Logger'
keys   = require './Keywords'

module.exports = class Report

  constructor: (file) ->
    @logger = new Logger()
    return @logger.error "You need to provide a file path." unless file
    @filename = path.basename file

  @default: haveRequiredErrors: false, haveMissingErrors: false

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

  successMessage: (cb) ->
    @logger.success("#{chalk.bold(@filename)} is now #{chalk.bold("fine")}!")
    cb(null, @logger.messages)

  requiredMessage: (cb) ->
    @logger.info("#{chalk.bold(@filename)} isn't #{chalk.bold('fine')}. Check the file and run again.")
    cb(true, @logger.messages)

  missingMessage: (cb) ->
    @logger.info("#{chalk.bold(@filename)} is near to be #{chalk.bold('fine')}. Check the file and run again.")
    cb(true, @logger.messages)

  alreadyMessage: (cb) ->
    @logger.info("#{chalk.bold(@filename)} is already #{chalk.bold("fine")}!")
    cb(null, @logger.messages)
