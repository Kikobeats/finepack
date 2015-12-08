#!/usr/bin/env node
'use strict'
require('coffee-script').register()
var pkg = require('../package.json')
require('update-notifier')({pkg: pkg}).notify()

var fs = require('fs')
var os = require('os')
var path = require('path')
var Logger = require('acho')
var finepack = require('./../lib/Finepack')
var existsDefault = require('existential-default')
var cli = require('meow')({
  pkg: pkg,
  help: [
    'Usage',
    '  $ finepack <fileJSON> [options]',
    '\n  options:',
    '\t --no-validate disable validate mode.',
    '\t --no-color\t disable colors in the output.',
    '\t --version\t output the current version.',
    '\n  examples:',
    '\t finepack package.json',
    '\t finepack bower.json --no-validate'
  ].join('\n')
})

if (cli.input.length === 0) cli.showHelp()

var filepath = path.resolve(cli.input[0])
var filename = path.basename(filepath)

var options = {
  filename: filename,
  validate: existsDefault((cli.flags.validate), true),
  lint: existsDefault((cli.flags.lint), true),
  color: existsDefault((cli.flags.color), true)
}

function stringify (data) {
  return JSON.stringify(data, null, 2) + os.EOL
}

fs.readFile(filepath, {encoding: 'utf8'}, function (err, filedata) {
  if (err) throw err

  finepack(filedata, options, function (error, output, messages) {
    var logger = new Logger({
      color: options.color,
      messages: messages
    })

    if (error) {
      logger.print()
      logger.error(output)
      return process.exit(1)
    }

    output = stringify(output)
    fs.writeFile(filepath, output, {encoding: 'utf8'}, function (err) {
      if (err) throw err
      console.log()
      logger.print()
    })
  })
})
