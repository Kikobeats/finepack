# finepack

![Last version](https://img.shields.io/github/tag/Kikobeats/finepack.svg?style=flat-square)
[![Build Status](http://img.shields.io/travis/Kikobeats/finepack/master.svg?style=flat-square)](https://travis-ci.org/Kikobeats/finepack)
[![Dependency status](http://img.shields.io/david/Kikobeats/finepack.svg?style=flat-square)](https://david-dm.org/Kikobeats/finepack)
[![Dev Dependencies Status](http://img.shields.io/david/dev/Kikobeats/finepack.svg?style=flat-square)](https://david-dm.org/Kikobeats/finepack#info=devDependencies)
[![NPM Status](http://img.shields.io/npm/dm/finepack.svg?style=flat-square)](https://www.npmjs.org/package/finepack)
[![Gittip](http://img.shields.io/gittip/Kikobeats.svg?style=flat-square)](https://www.gittip.com/Kikobeats/)

> Organizes and maintains readable your JSON files.

![](http://i.imgur.com/2qNLC48.png)

**Finepack** is a tool to keep your JSON files organized, specially if you are creating an open source project and want to be sure that your files have all the information that is necessary for the mainly packet systems (like bower or npm). With it you you'll:

- Lint the JSON to be sure that is in a valid format.
- Validates the keys for be sure that exists the required keys as `name` or `version` and other important keys as `homepage`, `main`, `license`,...
- Organizes a JSON putting the most important properties above.
- Sorts the rest of the keys alphabetically and recursively.

You can use as CLI tool or from NodeJS as a library more. Based in [fixpack](https://github.com/henrikjoreteg/fixpack) but with a little more of ♥.

## Install

```bash
npm install finepack -g
```

## Usage

```
$ finepack

  Organizes and maintains readable your JSON files

  Usage
    $ finepack <fileJSON> [options]

    options:
     --no-validate disable validation mode.
     --no-color    disable colors in the output.
     --version     output the current version.

    examples:
     finepack package.json
     finepack bower.json --no-validate
```

## API

For uses inside your NodeJS project, just install as normal dependency.

```js
var fs       = require('fs');
var path     = require('path');
var finepack = require('finepack');
var filepath = path.resolve('./package.json');
var filename = path.basename(filepath);
var filedata = fs.readFileSync(filepath, {encoding: 'utf8'});

var options = {
  filename: filename, // for customize the output messages, but is not necessary.
  validate: false, // For enable (or not) keys validation (false by default).
  color: false // For enable (or not) colorize or not the output (false by default).
}

finepack(filedata, options, function(err, output, messages){
  if (err){
    // if your JSON is malformed then you have an err
  }
});
```

## License

MIT © [Kiko Beats](http://www.kikobeats.com)
