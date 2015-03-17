#!/usr/bin/env node
'use strict';
require('coffee-script').register();
var fs = require('fs'),
path = require('path'),
existsDefault = require('existential-default'),
os = require('os'),
updateNotifier = require('update-notifier'),
finepack = require('./../lib/Finepack'),
Logger = require('acho'),
cli = require('meow')({
  pkg: '../package.json',
  help: [
      'Usage',
      '  $ finepack <fileJSON> [options]',
      '\n  options:',
      '\t --no-validation disable validation mode.',
      '\t --no-color\t disable colors in the output.',
      '\t --version\t output the current version.',
      '\n  examples:',
      '\t finepack package.json',
      '\t finepack bower.json --no-validation'
  ].join('\n')
});

updateNotifier({pkg: cli.pkg}).notify();
if (cli.input.length === 0) cli.showHelp();

var filepath = path.resolve(cli.input[0]);
var filename = path.basename(filepath);
var filedata = fs.readFileSync(filepath, {encoding: 'utf8'});

var options = {
  filename: filename,
  validation: existsDefault((cli.flags.validation), true),
  lint: existsDefault((cli.flags.lint), true),
  color: existsDefault((cli.flags.color), true),
};

// custom print method for acho
var print = function() {
  console.log();
  var _this = this;
  Object.keys(this.types).forEach(function(type) {
    _this.messages[type].forEach(function(message) {
      _this.printLine(type, message);
    });
  });
};

finepack(filedata, options, function(error, output, messages) {
  var fileoutput = JSON.stringify(output, null, 2) + os.EOL;
  fs.writeFile(filepath, fileoutput, {encoding: 'utf8'}, function(err) {
    var logger = new Logger({color: options.color, messages: messages, print: print});
    logger.print();
    if (error || err) return process.exit(1);
  });
});
