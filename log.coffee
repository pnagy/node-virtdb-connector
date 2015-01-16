Diag = require "./diag"
util = require 'util'

class Variable
    constructor: (@content) ->

    toString: () ->
        util.inspect @content, depth: null

class Log
    @levels =
        SILENT: 'silent'
        TRACE: 'trace'
        DEBUG: 'debug'
        INFO: 'info'
        WARN: 'warn'
        ERROR: 'error'

    @level = 'trace'

    @trace: (args...) ->
        if @level in ['trace']
            Diag._log 'VIRTDB_SIMPLE_TRACE', args

    @debug: (args...) ->
        if @level in ['trace', 'debug']
            Diag._log 'VIRTDB_SIMPLE_TRACE', args

    @info: (args...) ->
        if @level in ['trace', 'debug', 'info']
            Diag._log 'VIRTDB_INFO', args

    @warn: (args...) ->
        if @level in ['trace', 'debug', 'info', 'warn']
            Diag._log 'VIRTDB_INFO', args

    @error: (args...) ->
        if @level in ['trace', 'debug', 'info', 'warn', 'error']
            Diag._log 'VIRTDB_ERROR', args

    @setLevel: (level) =>
        @level = level.toLowerCase?()

    @enableAll: () =>
        @setLevel @levels.TRACE

    @disableAll: () =>
        @setLevel @levels.SILENT

    @enableConsoleLog: (isEnabled) =>
        Diag._isConsoleLogEnabled = isEnabled

    @Variable = (param) ->
        new Variable(param)


module.exports = Log