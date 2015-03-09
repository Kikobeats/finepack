#!/usr/bin/env node
'use strict';
require('coffee-script').register();
var fs = require('fs');
var path = require('path');
var os = require('os');
var updateNotifier = require('update-notifier');
var Finepack = require('./../lib/Finepack');
var Logger = require('./../lib/Logger');
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
if (cli.input.length === 0) cli.showHelp();

var filepath = path.resolve(cli.input[0]);
var filename = path.basename(filepath);
var filedata = fs.readFileSync(filepath, {encoding: 'utf8'});

var options = {
  filename: filename,
  lint: cli.flags.l ? false : true
};

Finepack(filedata, options, function(error, output, messages){
  var fileoutput = JSON.stringify(output, null, 2) + os.EOL;
  fs.writeFile(filepath, fileoutput, {encoding: 'utf8'}, function (err) {
    Logger.print(messages);
    if (error || err) return process.exit(1);
  });
});
