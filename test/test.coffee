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
    data = fs.readFileSync @fileNormal, {encoding: 'utf8'}
    options = filename: 'pkg.json'

    Finepack data, options, (err, output, messages) ->
      (err?).should.eql.false
      (messages.warning[0]?).should.be.equal false
      (messages.success[0]?).should.be.equal true
      (typeof output is 'object').should.be.equal true
      done()

  it 'Lint a file without important required keys', (done) ->
    data = fs.readFileSync @fileRequired, {encoding: 'utf8'}
    options = filename: 'pkg.json', lint: true

    Finepack data, options, (err, output, messages) ->
      (err?).should.be.equal true
      (messages.error[0]?).should.be.equal true
      (messages.info[0]?).should.be.equal true
      (typeof output is 'object').should.be.equal true
      done()

  it 'Lint file without recommended keys', (done) ->
    data = fs.readFileSync @fileMissing, {encoding: 'utf8'}
    options = filename: 'pkg.json', lint: true

    Finepack data, options, (err, output, messages) ->
      (err?).should.be.equal true
      (messages.warning[0]?).should.be.equal true
      (messages.info[0]?).should.be.equal true
      (typeof output is 'object').should.be.equal true
      done()

  it 'Lint a file that is already linted', (done) ->
    data = fs.readFileSync @fileNormal, {encoding: 'utf8'}
    options = filename: 'pkg.json', lint: true

    Finepack data, options, (err, output, messages) ->
      (err?).should.be.equal true
      (messages.info[0]?).should.be.equal true
      (typeof output is 'object').should.be.equal true
      done()
