'use strict'

should   = require 'should'
path     = require 'path'
fs       = require 'fs'
Finepack = require '..'

describe 'Finepack ::', ->

  before ->
    @fileNormal = path.resolve 'test/fixtures/pkg.json'
    @fileNormalBackup = path.resolve 'test/fixtures/pkg_backup.json'
    @fileMissing = path.resolve 'test/fixtures/pkg_missing.json'
    @fileMissingBackup = path.resolve 'test/fixtures/pkg_missing_backup.json'
    @fileRequired = path.resolve 'test/fixtures/pkg_required.json'
    @fileRequiredBackup = path.resolve 'test/fixtures/pkg_required_backup.json'
    @fileFixed = path.resolve 'test/fixtures/pkg_fixed.json'
    @fileFixedBackup = path.resolve 'test/fixtures/pkg_fixed_backup.json'
    @fileMalformed = path.resolve 'test/fixtures/pkg_malformed.json'
    @fileAlready = path.resolve 'test/fixtures/pkg_already_fine.json'

  beforeEach ->
    file = fs.readFileSync(@fileNormalBackup, encoding: 'utf8')
    fs.writeFileSync(@fileNormal, file, encoding: 'utf8')

    file = fs.readFileSync(@fileRequiredBackup, encoding: 'utf8')
    fs.writeFileSync(@fileRequired, file, encoding: 'utf8')

    file = fs.readFileSync(@fileMissingBackup, encoding: 'utf8')
    fs.writeFileSync(@fileMissing, file, encoding: 'utf8')

    file = fs.readFileSync(@fileFixedBackup, encoding: 'utf8')
    fs.writeFileSync(@fileFixed, file, encoding: 'utf8')

  describe 'Lint ::', ->
    it 'lint a malformed file', (done) ->
      data = fs.readFileSync @fileMalformed, {encoding: 'utf8'}
      options = filename: 'pkg.json'

      Finepack data, options, (err, output, messages) ->
        (err?).should.be.equal true
        (typeof output is 'object').should.be.equal true
        (messages.error[0]?).should.be.equal true
        done()

  describe 'Validate ::', ->
    it "doesn't validate by default", (done)  ->
      data = fs.readFileSync @fileNormal, {encoding: 'utf8'}
      options = filename: 'pkg.json'

      Finepack data, options, (err, output, messages) ->
        (err?).should.eql.false
        (messages.warn[0]?).should.be.equal false
        (messages.success[0]?).should.be.equal true
        (typeof output is 'object').should.be.equal true
        done()

    it 'Validate a file without important required keys', (done) ->
      data = fs.readFileSync @fileRequired, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        (err?).should.be.equal false
        (messages.error[0]?).should.be.equal true
        (messages.info[0]?).should.be.equal true
        (typeof output is 'object').should.be.equal true
        done()

    it 'Validate file without recommended keys', (done) ->
      data = fs.readFileSync @fileMissing, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        (err?).should.be.equal false
        (messages.warn[0]?).should.be.equal true
        (messages.info[0]?).should.be.equal true
        (typeof output is 'object').should.be.equal true
        done()

    it 'Validate a file that is already validated', (done) ->
      data = fs.readFileSync @fileAlready, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        (err?).should.be.equal false
        (messages.info[0]).should.be.equal 'pkg.json is already fine.'
        (typeof output is 'object').should.be.equal true
        done()
