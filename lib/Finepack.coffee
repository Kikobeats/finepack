'use strict'

fs                = require 'fs'
os                = require 'os'
path              = require 'path'
chalk             = require 'chalk'
Report            = require './Report'
Keywords          = require './Keywords'
recursiveSortKeys = require 'sort-keys-recursive'

###
  @description Organize the keys of JSON file.
  @param {object} options, that can be:
    - filepath: file to read.
    - lint: Activate keyword validations.
  @returns callback (error, data)
###
module.exports = (options, cb) ->
  report    = new Report options.filepath
  fileinput = fs.readFileSync options.filepath, encoding: 'utf8'
  filename  = path.basename options.filepath
  input     = JSON.parse fileinput
  output    = {}

  lint = if options.lint? then options.lint else false
  reporter = unless lint then Report.default else report.resume input
  return report.requiredMessage(cb) if reporter.haveRequiredErrors

  for key in Keywords.important when input[key]?
    output[key] = input[key]
    delete input[key]

  input = recursiveSortKeys input
  output[key] = value for key, value of input
  fileoutput = JSON.stringify(output, null, 2) + os.EOL
  fs.writeFileSync options.filepath, fileoutput, encoding: 'utf8'

  return report.missingMessage(cb) if reporter.haveMissingErrors
  return report.alreadyMessage(cb) if fileinput is fileoutput
  report.successMessage(cb)
