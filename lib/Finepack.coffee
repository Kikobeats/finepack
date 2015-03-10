'use strict'

Report            = require './Report'
Keywords          = require './Keywords'
recursiveSortKeys = require 'sort-keys-recursive'

isEquivalent = (objt1, objt2) ->
  JSON.stringify(objt1, null, 2) is JSON.stringify(objt2, null, 2)

###
  @description Organize the keys of JSON file.
  @param {object} options, that can be:
    - data: content of a file to rebuild.
    - options:
      * color {Boolean}: to indicate if put color in the messages.
      * lint {Boolean}: Activate keyword validations.
      * filename {String}: to customize the output messages
  @returns callback (error, data, messages)
###
module.exports = (data, options, cb) ->
  isLintEnable = options.lint or false
  report = new Report options.filename, options.color
  input  = if typeof data is 'string' then JSON.parse data else data
  output = {}

  reporter = if isLintEnable then report.resume input else Report.default
  return report.requiredMessage(cb, input) if reporter.haveRequiredErrors

  for key in Keywords.important when input[key]?
    output[key] = input[key]
    delete input[key]

  input = recursiveSortKeys input
  output[key] = value for key, value of input

  return report.missingMessage(cb, output) if reporter.haveMissingErrors
  return report.alreadyMessage(cb, output) if isEquivalent data, output
  report.successMessage(cb, output)
