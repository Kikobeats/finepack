#!/usr/bin/env node

'use strict'

require('coffeescript').register()

const loggerSkinCLI = require('acho-skin-cli')
const createLogger = require('acho')
const path = require('path')
const mri = require('mri')
const fs = require('fs')
const os = require('os')

const finepack = require('./../lib/Finepack')

const isNil = value => value === undefined || value === null

const isPrivate = filepath => {
  try {
    return JSON.parse(filepath).private
  } catch (_) {
    return false
  }
}

const help = [
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
].join('\n')

const { _: input, ...flags } = mri(process.argv.slice(2), {
  default: {
    ignoreObjectAtKeys: ['ava', 'exports'],
    validate: true
  }
})

if (flags.version) {
  console.log(require('../package.json').version)
  process.exit()
}

if (input.length === 0 || flags.help) {
  console.log(help)
  process.exit()
}

const cliFlagCsvToArray = (value = '') =>
  value
    .toString()
    .split(',')
    .filter(e => e)

const filepath = path.resolve(input[0] || 'package.json')
const filename = path.basename(filepath)

const options = {
  filename,
  validate: isNil(flags.validate) ? isPrivate(filepath) : flags.validate,
  color: flags.color
}

const sortOptions = {}
const ignoreObjectAtKeys = cliFlagCsvToArray(flags['sort-ignore-object-at'])
if (ignoreObjectAtKeys.length) Object.assign(sortOptions, { ignoreObjectAtKeys })
const ignoreArrayAtKeys = cliFlagCsvToArray(flags['sort-ignore-array-at'])
if (ignoreArrayAtKeys.length) Object.assign(sortOptions, { ignoreArrayAtKeys })
Object.assign(options, { sortOptions })

fs.readFile(filepath, { encoding: 'utf8' }, (error, filedata) => {
  if (error) throw error

  finepack(filedata, options, (error, output, messages) => {
    const log = createLogger({
      types: loggerSkinCLI,
      keyword: 'symbol',
      color: options.color,
      messages
    })

    if (error) {
      log.print()
      log.error(output)
      return process.exit(1)
    }

    output = JSON.stringify(output, null, 2) + os.EOL

    fs.writeFile(filepath, output, { encoding: 'utf8' }, error => {
      if (error) throw error
      console.log()
      log.print()
    })
  })
})
