'use strict'

Report        = require './Report'
Keywords      = require './Keywords'
normalize     = require './Normalize'
JSONisEqual   = require 'json-is-equal'
sort          = require 'sort-keys-recursive'

###
  @description Organize the keys of JSON file.
  @param {object} options, that can be:
    - data: content of a file to rebuild.
    - options:
      * color {Boolean}: Indicates if put color in the messages.
      * validate {Boolean}: Activates keyword validation.
      * filename {String}: Customizes the output messages
  @returns callback (error, data, messages)
###
module.exports = (data, options = {}, cb) ->
  return throw new Error "You need to provide 'data' parameter" unless data
  report = new Report options.filename, options.color, options.validate

  try
    report.lint data
  catch err
    return report.errorMessage cb, err

  input  = if typeof data is 'string' then JSON.parse data else data
  output = {}

  validation = report.validate input
  return report.requiredMessage(cb, input) if validation.required

  input = sort input
  for key in Keywords.important when input[key]?
    output[key] = input[key]
    delete input[key]
  output[key] = value for key, value of input

  output = normalize output

  return report.missingMessage(cb, output) if validation.missing
  return report.alreadyMessage(cb, output) if JSONisEqual data, output
  report.successMessage(cb, output)
