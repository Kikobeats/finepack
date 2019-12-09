#!/usr/bin/env node

'use strict'
require('coffeescript').register()
const pkg = require('../package.json')
require('update-notifier')({ pkg }).notify()

const fs = require('fs')
const os = require('os')
const path = require('path')
const createLogger = require('acho')
const loggerSkinCLI = require('acho-skin-cli')

const finepack = require('./../lib/Finepack')

const isNil = value => value === undefined || value === null

const isPrivate = filepath => {
  try {
    return JSON.parse(filepath).private
  } catch (err) {
    return false
  }
}

const cli = require('meow')({
  pkg,
  help: [
    'Usage',
    '  $ finepack <fileJSON> [options]',
    '\n  options:',
    '\t --no-validate\t\t   disable validate mode.',
    '\t --no-color\t\t   disable colors in the output.',
    "\t --sort-ignore-object-at   don't sort object(s) at these comma separated key(s).",
    "\t --sort-ignore-array-at    don't sort array(s) at these comma separated key(s).",
    '\t --version\t\t   output the current version.',
    '\n  examples:',
    '\t finepack package.json',
    '\t finepack bower.json --no-validate'
  ].join('\n'),
  flags: {
    validate: {
      type: 'boolean',
      default: true
    }
  }
})

const cliFlagCsvToArray = flagName =>
  cli.flags[flagName]
    .toString()
    .split(',')
    .filter(e => e)

const filepath = path.resolve(cli.input[0] || 'package.json')
const filename = path.basename(filepath)

let options = {
  filename,
  validate: isNil(cli.flags.validate)
    ? isPrivate(filepath)
    : cli.flags.validate,
  color: cli.flags.color
}

let sortOptions = {}

if (cli.flags.sortIgnoreObjectAt) {
  const ignoreObjectAtKeys = cliFlagCsvToArray('sortIgnoreObjectAt')

  if (ignoreObjectAtKeys.length) {
    sortOptions = Object.assign({}, sortOptions, { ignoreObjectAtKeys })
  }
}

if (cli.flags.sortIgnoreArrayAt) {
  const ignoreArrayAtKeys = cliFlagCsvToArray('sortIgnoreArrayAt')

  if (ignoreArrayAtKeys.length) {
    sortOptions = Object.assign({}, sortOptions, { ignoreArrayAtKeys })
  }
}

options = Object.assign({}, options, { sortOptions })

const stringify = data => {
  return JSON.stringify(data, null, 2) + os.EOL
}

fs.readFile(filepath, { encoding: 'utf8' }, (err, filedata) => {
  if (err) throw err

  finepack(filedata, options, (error, output, messages) => {
    const log = createLogger({
      types: loggerSkinCLI,
      keyword: 'symbol',
      color: options.color,
      messages: messages
    })

    if (error) {
      log.print()
      log.error(output)
      return process.exit(1)
    }

    output = stringify(output)

    fs.writeFile(filepath, output, { encoding: 'utf8' }, err => {
      if (err) throw err
      console.log()
      log.print()
    })
  })
})
