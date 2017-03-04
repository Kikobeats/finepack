'use strict'

Report      = require './Report'
KEYWORDS    = require './Keywords'
normalize   = require './Normalize'
JSONisEqual = require 'json-is-equal'
defaults    = require 'lodash.defaults'
sort        = require 'sort-keys-recursive'

DEFAULT =
  color: true
  validate: true
  filename: ''

###
  @description Sort the keys of an object by the order they appear in 'keyList'.
  @note Any key that is defined in 'obj' but not in 'keyList' will be ignored.
  * @param  {obj} object An object literal.
###
sortObjectKeysBy = (obj, keyList) ->
  keyList.reduce (acc, key) -> # Function, first argument of reduce().
    acc[key] = obj[key]
    acc
  , {} # Object, second argument of reduce(), initial value of 'acc'.

###
  @description Organize the keys of a JSON file.
  * @param  {string} data
  * @param  {opts} object
  * @param  [boolean] opts.color    Activates the colorization of the messages.
  * @param  [boolean] opts.validate Activates keyword validation.
  * @param  [string]  opts.filename Customizes the output messages.
  * @param  [object]  opts.sortOptions Customizes the sort options.
###
module.exports = (data, opts = {}, cb) ->
  return cb new TypeError("Need to provide 'data' parameter") unless data
  defaults(opts, DEFAULT)

  report = new Report opts.filename, opts.color, opts.validate

  # We only handle well formed data.
  try
    report.lint data
  catch err
    return report.errorMessage cb, err

  input = if typeof data is 'string' then JSON.parse data else data

  # We try to normalize the metadata; if it fails no problem, it will be detected
  # in the validation step.
  try
    input  = normalize input
  catch err

  output = {}

  validation = report.validate input
  return report.requiredMessage(cb, input) if validation.required

  # Default sort order is alphabetical but not equivalent to sort((a,b) => a > b)
  # in various cases i.e when numbers, booleans ... are involved. This is how it
  # works: "Elements are sorted by converting them to strings and comparing
  # strings in Unicode code point order". SEE: https://mzl.la/1jBtmgE
  input = sort input, opts.sortOptions

  # After sorting, we move some fields in new positions for esthetic effect.
  # First, we get all 'KEYWORDS.sort' that are in 'input'; no need to sort them,
  # they are already in the correct order defined in './lib/Keywords.coffee'.
  specialKeys = KEYWORDS.sort.filter (k) ->
    Object.prototype.hasOwnProperty.call(input, k)

  # We get all the "non-special" keys in 'input'. We don't sort them, they
  # were alphabetically sorted (or maybe sorted in a custom order, if the user
  # passed a 'compareFunction') by 'sort-keys-recursive' (see above).
  otherKeys = Object.keys(input).filter (e) -> KEYWORDS.sort.indexOf(e) == -1

  # We add the "special" keys before the rest of the keys.
  orderedInputKeys = [specialKeys..., otherKeys...]

  # We sort the keys in 'input' by the order they appear in 'orderedInputKeys'.
  output = sortObjectKeysBy input, orderedInputKeys

  return report.missingMessage(cb, output) if validation.missing
  return report.alreadyMessage(cb, output) if JSONisEqual data, output

  report.successMessage(cb, output)
