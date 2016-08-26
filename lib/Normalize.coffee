'use strict'

normalizeData = require 'normalize-package-data'
omit = require 'lodash.omit'

CONST =
  STRICT_MODE: true
  EXCLUDE_FIELDS: ['readme', '_id']

normalize = (json) ->
  normalizeData json, CONST.STRICT_MODE
  omit json, CONST.EXCLUDE_FIELDS

module.exports = normalize
