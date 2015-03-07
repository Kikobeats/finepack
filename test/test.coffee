should   = require 'should'
path     = require 'path'
fs       = require 'fs'
Finepack = require '..'
Logger   = require './../lib/Logger'

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

  beforeEach ->
    file = fs.readFileSync(@fileNormalBackup, encoding: 'utf8')
    fs.writeFileSync(@fileNormal, file, encoding: 'utf8')

    file = fs.readFileSync(@fileRequiredBackup, encoding: 'utf8')
    fs.writeFileSync(@fileRequired, file, encoding: 'utf8')

    file = fs.readFileSync(@fileMissingBackup, encoding: 'utf8')
    fs.writeFileSync(@fileMissing, file, encoding: 'utf8')

    file = fs.readFileSync(@fileFixedBackup, encoding: 'utf8')
    fs.writeFileSync(@fileFixed, file, encoding: 'utf8')


  it "doesn't validate by default", (done)  ->
    options =
      filePath: @fileNormal

    Finepack options, (err, data) ->
      (err?).should.eql.false
      (data.warning[0]?).should.be.equal false
      (data.success[0]?).should.be.equal true
      done()

  it 'Lint a file without important required keys', (done) ->
    options =
      filePath: path.resolve @fileRequired
      lint : true

    Finepack options, (err, data) ->
      (err?).should.be.equal true
      (data.error[0]?).should.be.equal true
      (data.info[0]?).should.be.equal true
      done()

  it 'Lint file without recommended keys', (done) ->
    options =
      filePath: path.resolve @fileMissing
      lint : true

    Finepack options, (err, data) ->
      (err?).should.be.equal true
      (data.warning[0]?).should.be.equal true
      (data.info[0]?).should.be.equal true
      done()

  it 'Lint a file that is already linted', (done) ->
    options =
      filePath: path.resolve @fileNormal
      lint : true

    Finepack options, (err, data) ->
      (err?).should.be.equal true
      (data.info[0]?).should.be.equal true
      done()
