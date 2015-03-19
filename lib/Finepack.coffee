'use strict'

Report            = require './Report'
Keywords          = require './Keywords'
recursiveSortKeys = require 'sort-keys-recursive'
existsDefault     = require 'existential-default'
JsonIsEqual       = require 'json-is-equal'

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

  for key in Keywords.important when input[key]?
    output[key] = input[key]
    delete input[key]

  input = recursiveSortKeys input
  output[key] = value for key, value of input

  return report.missingMessage(cb, output) if validation.missing
  return report.alreadyMessage(cb, output) if JsonIsEqual data, output
  report.successMessage(cb, output)
