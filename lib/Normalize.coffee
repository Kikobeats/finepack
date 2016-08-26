'use strict'

normalizeData = require 'normalize-package-data'
omit = require 'lodash.omit'

CONST =
  STRICT_MODE: true
  EXCLUDE_FIELDS: [
    '_npmOperationalInternal'
    'directories'
    'readme'
    '_id'
    '_shasum'
    '_from'
    'npmVersion'
  ]

normalize = (json) ->
  normalizeData json, CONST.STRICT_MODE
  omit json, CONST.EXCLUDE_FIELDS

module.exports = normalize
