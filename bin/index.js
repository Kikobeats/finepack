#!/usr/bin/env node
'use strict';
require('coffee-script').register();
var updateNotifier = require('update-notifier');
var path = require('path');
var Finepack = require('./../lib/Finepack');
var Logger = require('./../lib/Logger')
var cli = require('meow')({
  pkg: '../package.json',
  help: [
      'Usage',
      '  $ finepack <fileJSON> [options]',
      '\n  options:',
      '\t -l\t     disable lint mode.',
      '\t --version   output the current version.',
      '\n  examples:',
      '\t finepack package.json',
      '\t finepack bower.json -l',
  ].join('\n')
});

updateNotifier({pkg: cli.pkg}).notify();
if (cli.input.length === 0) cli.showHelp()

var options = {
  filepath: path.resolve(cli.input[0]),
  lint: cli.flags.l || true
}

Finepack(options, function(err, messages){
  Logger.print(messages);
  if (err) return process.exit(1);
})
