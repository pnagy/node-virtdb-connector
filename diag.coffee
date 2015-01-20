Protocol = require './protocol'
os = require 'os'

Date::yyyymmdd = () ->
    yyyy = @getFullYear().toString()
    mm = (@getMonth() + 1).toString() # getMonth() is zero-based
    dd = @getDate().toString()
    yyyy + ((if mm[1] then mm else "0" + mm[0])) + ((if dd[1] then dd else "0" + dd[0])) # padding

Date::hhmmss = () ->
    hh = ('0'+@getHours().toString()).slice(-2)
    mm = ('0'+@getMinutes().toString()).slice(-2)
    ss = ('0'+@getSeconds().toString()).slice(-2)
    hh + mm + ss

Object.defineProperty global, "__stack",
    get: ->
        orig = Error.prepareStackTrace
        Error.prepareStackTrace = (_, stack) ->
            stack

        err = new Error
        Error.captureStackTrace err, arguments.callee
        stack = err.stack
        Error.prepareStackTrace = orig
        stack

Object.defineProperty global, "__line",
    get: ->
        __stack[4].getLineNumber()

Object.defineProperty global, "__file",
    get: ->
        name = __stack[4].getFileName()
        name.substring process.cwd().length, name.length

Object.defineProperty global, "__func",
    get: ->
        __stack[4].getFunctionName() or ""


class Diag
    @_startHR = null
    @_startDate = null
    @_startTime = null
    @_random = null
    @_name = null
    @_symbols = {}
    @_newSymbols = []
    @_headers = {}
    @_newHeaders = []
    @isConsoleLogEnabled = false
    @componentName = null

    @startDate: =>
        if not @_startDate?
            @_startDate = new Date().yyyymmdd()
        @_startDate

    @startTime: =>
        if not @_startTime?
            @_startTime = new Date().hhmmss()
        @_startTime

    @random: =>
        if not @_random?
            @_random = Math.floor(Math.random() * 100000000 + 1)
        @_random

    @_getProcessInfo: () =>
        Process =
            StartDate: @startDate()
            StartTime: @startTime()
            Pid: process.pid
            Random: @random()
            NameSymbol: @_getSymbolSeqNo @componentName
            HostSymbol: @_getSymbolSeqNo os.hostname()
        return Process

    @_getNewSymbols: () =>
        Symbols = []
        for symbol in @_newSymbols
            Symbols.push symbol
        return Symbols

    @_getNewHeaders: () =>
        Headers = []
        for header in @_newHeaders
            Headers.push header
        return Headers

    @_clearSentHeadersAndSymbols: () =>
        @_newHeaders = []
        @_newSymbols = []

    @_getSymbolSeqNo: (symbolValue) =>
        if symbolValue not of @_symbols
            @_symbols[symbolValue] = Object.keys(@_symbols).length
            @_newSymbols.push
                SeqNo: @_symbols[symbolValue]
                Value: symbolValue
        return @_symbols[symbolValue]

    @_getHeaderSeqNo: (file, func, line, level, args) =>
        key = '' + file + func + line + level + args.length
        if key not of @_headers
            @_headers[key] =
                SeqNo: Object.keys(@_headers).length
                FileNameSymbol: @_getSymbolSeqNo file
                LineNumber: line
                FunctionNameSymbol: @_getSymbolSeqNo func
                Level: level
                LogStringSymbol: 0
                Parts: []
            for argument in args
                switch typeof argument
                    when 'object'
                        @_headers[key].Parts.push
                            IsVariable: true
                            HasData: true
                            Type: 'STRING'
                    else
                        @_headers[key].Parts.push
                            IsVariable: false
                            HasData: false
                            Type: 'STRING'
                            PartSymbol: @_getSymbolSeqNo argument
            @_newHeaders.push @_headers[key]
        return @_headers[key].SeqNo

    @_value: (argument) ->
        switch  typeof argument
            when 'string'
                ret =
                    Type: 'STRING'
                    StringValue: [
                        argument
                    ]
                    IsNull: [
                        false
                    ]
            when 'number'
                if not isFinite(argument)
                    ret =
                        Type: 'STRING'
                        StringValue: [
                            argument
                        ]
                        IsNull: [
                            false
                        ]
                else if argument % 1 == 0
                    ret =
                        Type: 'INT64'
                        Int64Value: [
                            argument
                        ]
                        IsNull: [
                            false
                        ]
                else
                    ret =
                        Type: 'DOUBLE'
                        DoubleValue: [
                            argument
                        ]
                        IsNull: [
                            false
                        ]
            else
                ret =
                    Type: 'STRING'
                    StringValue: [
                        argument?.toString()
                    ]
                    IsNull: [
                        not argument?
                    ]

    @_ellapsedMicrosec: () =>
        if not @_startHR?
            @_startHR = process.hrtime()
        ellapsed = process.hrtime(@_startHR)
        return (ellapsed[0] * 1e9 + ellapsed[1]) / 1000

    @_createConsoleLogMessage: (args) =>
        message = ""
        argTexts = args.map (val) ->
            val.toString()
        return argTexts.join " "

    @_createDiagServiceMessage: (level, args) =>

        record = {}
        record.Process = @_getProcessInfo()
        record.Data = [
                HeaderSeqNo: @_getHeaderSeqNo(__file, __func, __line, level, args)
                ElapsedMicroSec: @_ellapsedMicrosec()
                ThreadId: 0
                Values: []
            ]
        for argument in args
            type = typeof(argument)
            switch  type
                when 'object'
                    record.Data[0].Values.push @_value(argument)

        record.Symbols = @_getNewSymbols()
        record.Headers = @_getNewHeaders()
        return record


    @log: (level, args) =>
        isSendingSuccessful = Protocol.sendDiag @_createDiagServiceMessage level, args

        if isSendingSuccessful
            @_clearSentHeadersAndSymbols()

        if (Diag.isConsoleLogEnabled is true) or (not isSendingSuccessful)
            console.log level + ": " + @_createConsoleLogMessage args

module.exports = Diag
