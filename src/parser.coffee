do ->
  matcher = require './matcher'

  module.exports = (nzb) ->
    return matcher nzb
