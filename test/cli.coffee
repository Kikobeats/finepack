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

  it 'prints messages with symbols on stdout', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{"z":2,"a":1}'
    result = @run ['--no-validate', '--no-color']
    assert.strictEqual result.stdout, os.EOL + '✔ package.json is now fine.' + os.EOL

  it 'disables colors with --no-color even when the terminal forces them', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{"z":2,"a":1}'
    result = spawnSync process.execPath, [cli, '--no-color'],
      cwd: @directory
      encoding: 'utf8'
      env: Object.assign {}, process.env, FORCE_COLOR: '1'
    assert.strictEqual result.status, 0
    assert.ok !/\u001b\[/.test(result.stdout), JSON.stringify(result.stdout)
    assert.ok result.stdout.includes("missing 'bugs'."), result.stdout

  it 'reports an empty file without a stack trace', ->
    filepath = path.join @directory, 'package.json'
    fs.writeFileSync filepath, ''
    result = @run ['--no-color']
    assert.strictEqual result.status, 1
    assert.strictEqual result.stderr, ''
    assert.strictEqual result.stdout, "✖ Need to provide 'data' parameter" + os.EOL
    assert.strictEqual fs.readFileSync(filepath, 'utf8'), ''

  it 'mirrors every message to debug-logfmt under DEBUG=finepack*', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{"z":2,"a":1}'
    result = spawnSync process.execPath, [cli, '--no-color'],
      cwd: @directory
      encoding: 'utf8'
      env: Object.assign {}, process.env, DEBUG: 'finepack*', DEBUG_COLORS: 'false'
    assert.strictEqual result.status, 0
    assert.ok result.stderr.includes("finepack:info package.json isn't fine."), result.stderr
    assert.ok result.stderr.includes("finepack:warn missing 'bugs'."), result.stderr
    assert.ok result.stderr.includes("finepack:error required 'name'."), result.stderr

  it 'mirrors the success message and the error reason to debug-logfmt', ->
    filepath = path.join @directory, 'x%o.json'
    fs.writeFileSync filepath, '{"z":2,"a":1}'
    env = Object.assign {}, process.env, DEBUG: 'finepack*', DEBUG_COLORS: 'false'
    ok = spawnSync process.execPath, [cli, 'x%o.json', '--no-validate'], cwd: @directory, encoding: 'utf8', env: env
    assert.ok ok.stderr.includes('finepack:success x%o.json is now fine.'), ok.stderr
    fs.writeFileSync filepath, '{not json}'
    bad = spawnSync process.execPath, [cli, 'x%o.json'], cwd: @directory, encoding: 'utf8', env: env
    assert.strictEqual bad.status, 1
    assert.ok bad.stderr.includes('finepack:error Something in x%o.json is wrong.'), bad.stderr
    assert.ok bad.stderr.includes('Parse error on line 1'), bad.stderr
    fs.unlinkSync filepath

  it 'stays silent on stderr without DEBUG', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{"z":2,"a":1}'
    env = Object.assign {}, process.env
    delete env.DEBUG
    result = spawnSync process.execPath, [cli, '--no-color'], cwd: @directory, encoding: 'utf8', env: env
    assert.strictEqual result.stderr, ''

  it 'prints exact colored output when the terminal forces colors', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{"z":2,"a":1}'
    result = spawnSync process.execPath, [cli, '--no-validate'],
      cwd: @directory, encoding: 'utf8', env: Object.assign {}, process.env, FORCE_COLOR: '1'
    assert.strictEqual result.stdout, os.EOL + '\u001b[38;2;51;255;102m✔\u001b[39m package.json is now fine.' + os.EOL

  it 'paints message text gray with --color', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{"z":2,"a":1}'
    result = spawnSync process.execPath, [cli, '--no-validate', '--color'],
      cwd: @directory, encoding: 'utf8', env: Object.assign {}, process.env, FORCE_COLOR: '1'
    assert.strictEqual result.stdout, os.EOL + '\u001b[38;2;51;255;102m✔\u001b[39m \u001b[90mpackage.json is now fine.\u001b[39m' + os.EOL

  it 'prints the exact malformed JSON report', ->
    fs.writeFileSync path.join(@directory, 'package.json'), '{not json}'
    result = @run ['--no-color']
    assert.strictEqual result.stdout, [
      '✖ Something in package.json is wrong. See below.'
      '✖ Parse error on line 1:'
      '{not json}'
      '-^'
      "Expecting 'STRING', '}', got 'undefined'"
    ].join(os.EOL) + os.EOL

