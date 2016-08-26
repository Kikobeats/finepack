'use strict'

module.exports =
  wrong: (name) -> "Something in #{name} is wrong. See below."
  success: (name) -> "#{name} is now fine."
  notFine: (name) -> "#{name} isn't fine. Check the file and run again."
  almostFine: (name) -> "#{name} is almost fine. Check the file and run again."
  alreadyFine: (name) -> "#{name} is already fine."
  allIsFine: (name) -> "#{name} is now fine."
  required: (key) -> "required '#{key}'."
  missing: (key) -> "missing '#{key}'."
