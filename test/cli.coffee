'use strict'

assert = require 'assert'
fs = require 'fs'
os = require 'os'
path = require 'path'
{spawnSync} = require 'child_process'

cli = path.resolve __dirname, '../bin/index.js'

describe 'CLI file reads ::', ->
  @timeout 10000

  beforeEach ->
    @directory = fs.mkdtempSync path.join(os.tmpdir(), 'finepack-cli-')
    @run = (args = []) =>
      spawnSync process.execPath, [cli].concat(args),
        cwd: @directory
        encoding: 'utf8'
        timeout: 5000

  afterEach ->
    for filename in fs.readdirSync @directory
      fs.unlinkSync path.join(@directory, filename)
    fs.rmdirSync @directory

  for scenario in [
    {name: 'explicit missing path', args: ['missing package.json'], code: 'ENOENT', filename: 'missing package.json'}
    {name: 'missing default package.json', args: [], code: 'ENOENT', filename: 'package.json'}
    {name: 'directory instead of a file', args: ['.'], code: 'EISDIR', filename: '.'}
  ]
    do (scenario) ->
      it "reports #{scenario.name} without a stack trace or writes", ->
        result = @run scenario.args
        assert.ifError result.error
        assert.strictEqual result.status, 1
        assert.strictEqual result.signal, null
        assert.strictEqual result.stdout, ''
        assert.ok result.stderr.startsWith('finepack: '), result.stderr
        assert.ok result.stderr.includes(scenario.code), result.stderr
        assert.ok result.stderr.includes(path.resolve(@directory, scenario.filename)), result.stderr
        assert.strictEqual result.stderr.trim().split(/\r?\n/).length, 1
        assert.deepStrictEqual fs.readdirSync(@directory), []

  it 'still formats a readable file', ->
    filepath = path.join @directory, 'package.json'
    fs.writeFileSync filepath, '{"z":2,"a":1}'
    result = @run ['--no-validate', '--no-color']
    assert.ifError result.error
    assert.strictEqual result.status, 0
    assert.strictEqual result.stderr, ''
    output = fs.readFileSync filepath, 'utf8'
    assert.deepStrictEqual Object.keys(JSON.parse(output)), ['a', 'z']
    assert.strictEqual output, JSON.stringify({a: 1, z: 2}, null, 2) + os.EOL

  it 'still rejects malformed JSON without rewriting it', ->
    filepath = path.join @directory, 'package.json'
    source = '{not json}'
    fs.writeFileSync filepath, source
    result = @run ['--no-color']
    assert.ifError result.error
    assert.strictEqual result.status, 1
    assert.strictEqual fs.readFileSync(filepath, 'utf8'), source
    assert.ok !result.stderr.includes('finepack: ')
