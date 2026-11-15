'use strict'

assert = require 'assert'
Logger = require '../lib/Logger'

ANSI = /\u001b\[/

describe 'Logger ::', ->
  it 'collects every message type in a plain object', ->
    logger = new Logger()
    logger.push('warn', "missing 'bugs'.").push('error', "required 'name'.")
    assert.deepStrictEqual logger.messages,
      debug: [], info: [], success: [], warn: ["missing 'bugs'."], error: ["required 'name'."]

  it 'renders grouped by type, not by push order', ->
    lines = Logger.render {error: ['boom'], info: ['hello'], warn: ['careful']}, color: false
    assert.deepStrictEqual lines.map((line) -> line.split(' ').slice(1).join(' ')), ['hello', 'careful', 'boom']

  it 'prefixes each line with its type symbol', ->
    [info, success, warn, error] = Logger.render {info: ['a'], success: ['b'], warn: ['c'], error: ['d']}, color: false
    figures = if process.platform is 'win32' then ['i', '√', '‼', '×'] else ['ℹ', '✔', '⚠', '✖']
    assert.deepStrictEqual [info, success, warn, error], figures.map (symbol, index) -> "#{symbol} #{'abcd'[index]}"

  it 'strips colors when color is false', ->
    assert.ok !ANSI.test Logger.render({error: ['boom']}, color: false).join('')

  it 'tolerates missing or partial messages', ->
    assert.deepStrictEqual Logger.render(), []
    assert.deepStrictEqual Logger.render({warn: ['x']}, color: false).length, 1
