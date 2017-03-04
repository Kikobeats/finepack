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
    @fileCustomProperty = path.resolve 'test/fixtures/pkg_custom_properties.json'

  beforeEach ->
    file = fs.readFileSync(@fileNormalBackup, encoding: 'utf8')
    fs.writeFileSync(@fileNormal, file, encoding: 'utf8')

    file = fs.readFileSync(@fileRequiredBackup, encoding: 'utf8')
    fs.writeFileSync(@fileRequired, file, encoding: 'utf8')

    file = fs.readFileSync(@fileMissingBackup, encoding: 'utf8')
    fs.writeFileSync(@fileMissing, file, encoding: 'utf8')

    file = fs.readFileSync(@fileFixedBackup, encoding: 'utf8')
    fs.writeFileSync(@fileFixed, file, encoding: 'utf8')

  describe 'Linter ::', ->
    it 'lint a malformed file', (done) ->
      data = fs.readFileSync @fileMalformed, {encoding: 'utf8'}
      options = filename: 'pkg.json'

      Finepack data, options, (err, output, messages) ->
        (err?).should.be.equal true
        output.should.be.Object()
        (messages.error[0]?).should.be.equal true
        done()

  describe 'Validator ::', ->
    it "doesn't validate by default", (done)  ->
      data = fs.readFileSync @fileNormal, {encoding: 'utf8'}
      options = filename: 'pkg.json'

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        (messages.warn[0]?).should.be.equal false
        (messages.success[0]?).should.be.equal true
        output.should.be.Object()
        done()

    it 'validate a file without important required keys', (done) ->
      data = fs.readFileSync @fileRequired, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        (messages.error[0]?).should.be.equal true
        (messages.info[0]?).should.be.equal true
        output.should.be.Object()
        done()

    it 'validate file without recommended keys', (done) ->
      data = fs.readFileSync @fileMissing, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        (messages.warn[0]?).should.be.equal true
        (messages.info[0]?).should.be.equal true
        output.should.be.Object()
        done()

    it 'validate a file that is already validated', (done) ->
      data = fs.readFileSync @fileAlready, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        (messages.info[0]).should.be.equal 'pkg.json is already fine.'
        output.should.be.Object()
        done()

    it 'sort keywords', (done) ->
      data = fs.readFileSync @fileMissing, {encoding: 'utf8'}
      options = filename: 'pkg.json', validate: true

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        (messages.warn[0]?).should.be.equal true
        (messages.info[0]?).should.be.equal true
        output.should.be.Object()
        output.keywords.should.be.eql([ 'cleanup', 'cli', 'package', 'tool' ])
        done()

    it 'sort \'special\' keys before the other keys', (done) ->
      data = fs.readFileSync @fileCustomProperty, {encoding: 'utf8'}
      options = filename: 'pkg.json'

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        output.should.be.Object()

        # Expect the three keys not included in './lib/Keywords.coffee' > 'sort'
        # to be at the end of the 'output' object and sorted alphabetically.
        expectedKeys = ['aCustomKey', 'secondCustomKey', 'thirdCustomKey']
        Object.keys(output).slice(-3).should.be.eql(expectedKeys)

        done()

    it 'sort \'special\' keys before the other keys (+ \'compareFunction\')', (done) ->
      data = fs.readFileSync @fileCustomProperty, {encoding: 'utf8'}
      compareFunction = (a, b) -> a < b
      options = filename: 'pkg.json', sortOptions:{ compareFunction}

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        output.should.be.Object()

        # Expect the three keys not included in './lib/Keywords.coffee' > 'sort'
        # to be at the end of the 'output' object. Also expect them to have been
        # sorted in reverse alphabetical order by 'compareFunction'.
        expectedKeys = ['thirdCustomKey', 'secondCustomKey', 'aCustomKey']
        Object.keys(output).slice(-3).should.be.eql(expectedKeys)

        done()

    it 'validate file > options.sortOptions.compareFunction', (done) ->
      data = fs.readFileSync @fileCustomProperty, {encoding: 'utf8'}
      compareFunction = (a, b) -> a > b
      options = filename: 'pkg.json', sortOptions:{compareFunction}

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        output.should.be.Object()

        # Expect the elements of 'foo' to be in the original positions.
        output.aCustomKey.anObject.foo.should.be.eql([true, {bar: "baz"}])

        done()

    it 'validate file > options.sortOptions.ignoreArrayAtKeys', (done) ->
      data = fs.readFileSync @fileCustomProperty, {encoding: 'utf8'}
      options = filename: 'pkg.json', sortOptions:{ignoreArrayAtKeys: ['anArray']}

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        output.should.be.Object()

        # Expect 'foo' to be sorted according to "string Unicode code points",
        # which means object before boolean in this case.
        output.aCustomKey.anObject.foo.should.be.eql([{bar: "baz"}, true])
        # Expect the original 'anArray' to be "untouched", not sorted.
        output.aCustomKey.anArray.should.be.eql(['nine', 'eight', 'ten'])

        done()

    it 'validate file > options.sortOptions.ignoreObjectAtKeys', (done) ->
      data = fs.readFileSync @fileCustomProperty, {encoding: 'utf8'}
      options = filename: 'pkg.json', sortOptions:{ignoreObjectAtKeys: ['anObject']}

      Finepack data, options, (err, output, messages) ->
        should(err).be.null()
        output.should.be.Object()

        # Expect the original 'foo' to be "untouched", not sorted. It is a child
        # of the object 'anObject', specified in 'ignoreObjectAtKeys'.
        output.aCustomKey.anObject.foo.should.be.eql([true, {bar: "baz"}])
        # Expect 'anArray' to be alphabetically sorted.
        output.aCustomKey.anArray.should.be.eql(['eight', 'nine', 'ten'])

        done()
