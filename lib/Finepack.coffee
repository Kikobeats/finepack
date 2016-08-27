'use strict'

Report        = require './Report'
KEYWORDS      = require './Keywords'
normalize     = require './Normalize'
JSONisEqual   = require 'json-is-equal'
sort          = require 'sort-keys-recursive'
defaults      = require 'lodash.defaults'

DEFAULT =
  color: true
  validate: true
  filename: ''

###
  @description Organize the keys of JSON file.
  * @param  {string} data
  * @param  {opts} object
  * @param  [boolean] opts.color    Indicates if put color in the messages.
  * @param  [boolean] opts.validate Activates keyword validation.
  * @param  [string]  opts.filename Customizes the output messages
###
module.exports = (data, opts = {}, cb) ->
  return cb new TypeError("Need to provide 'data' parameter") unless data
  defaults(opts, DEFAULT)

  report = new Report opts.filename, opts.color, opts.validate

  try
    report.lint data
  catch err
    return report.errorMessage cb, err

  input  = normalize(if typeof data is 'string' then JSON.parse data else data)
  output = {}

  validation = report.validate input
  return report.requiredMessage(cb, input) if validation.required

  input = sort input

  for key in KEYWORDS.sort when input[key]?
    output[key] = input[key]
    delete input[key]
  output[key] = value for key, value of input

  return report.missingMessage(cb, output) if validation.missing
  return report.alreadyMessage(cb, output) if JSONisEqual data, output
  report.successMessage(cb, output)
