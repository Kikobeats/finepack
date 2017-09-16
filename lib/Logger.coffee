'use strict'

acho = require 'acho'
skinCLI = require 'acho-skin-cli'

module.exports = (opts) ->
  acho(Object.assign({types: skinCLI}, opts))
