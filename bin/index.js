#!/usr/bin/env node
'use strict';
require('coffee-script').register();
var fs = require('fs');
var path = require('path');
var os = require('os');
var updateNotifier = require('update-notifier');
var Finepack = require('./../lib/Finepack');
var Logger = require('acho');
var cli = require('meow')({
  pkg: '../package.json',
  help: [
      'Usage',
      '  $ finepack <fileJSON> [options]',
      '\n  options:',
      '\t --no-lint\t disable lint mode.',
      '\t --no-colors\t disable colors in the output.',
      '\t --version\t output the current version.',
      '\n  examples:',
      '\t finepack package.json',
      '\t finepack bower.json --no-lint'
  ].join('\n')
});

updateNotifier({pkg: cli.pkg}).notify();
if (cli.input.length === 0) cli.showHelp();

var filepath = path.resolve(cli.input[0]);
var filename = path.basename(filepath);
var filedata = fs.readFileSync(filepath, {encoding: 'utf8'});

var options = {
  filename: filename,
  lint: cli.flags.lint != null ? cli.flags.lint : true,
  color: cli.flags.colors != null ? cli.flags.colors : true
};

// custom print method
var print = function() {
  // var isFinalMessage = false;
  // var isWarningOrErrorMessage = (this.messages.warning.length !== 0) || (this.messages.error.length !== 0);
  // var isSuccessOrInfoMessage = function(type) {
  //   if (isFinalMessage) return false;
  //   if ((type === 'success') || (type === 'info'))
  //     return isFinalMessage = true;
  // };
  // if (isWarningOrErrorMessage)

  console.log();
  var _this = this;
  Object.keys(this.types).forEach(function(type) {
    // if (isSuccessOrInfoMessage(type)) console.log();
    _this.messages[type].forEach(function(message) {
      _this.printLine(type, message);
    });
  });
};

Finepack(filedata, options, function(error, output, messages) {
  var fileoutput = JSON.stringify(output, null, 2) + os.EOL;
  fs.writeFile(filepath, fileoutput, {encoding: 'utf8'}, function(err) {
    var logger = new Logger({color: options.color, messages: messages, print: print});
    logger.print();
    if (error || err) return process.exit(1);
  });
});
