Diag = require "../diag"
Protocol = require "../protocol"
util = require "util"
os = require "os"

chai = require "chai"
chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

describe "Diag log", ->

    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        Diag.isConsoleLogEnabled = false
        sandbox.restore()

    it "should log the message to the console when flag is switched on", ->
        LEVEL = "loglevel"
        ARGS = "args"
        LOG_MSG = "logmsg"
        CONSOLE_MSG = LEVEL + ": " + LOG_MSG
        RECORD = "RECORD"

        consoleLogSpy = sandbox.spy console, "log"
        createDiagServiceMessageStub = sandbox.stub Diag, "_createDiagServiceMessage"
        createDiagServiceMessageStub.returns RECORD
        createConsoleLogMessageStub = sandbox.stub Diag, "_createConsoleLogMessage"
        protocolSendStub = sandbox.stub Protocol, "sendDiag"
        protocolSendStub.returns true
        createConsoleLogMessageStub.returns LOG_MSG
        Diag.isConsoleLogEnabled = true

        Diag.log LEVEL, ARGS

        consoleLogSpy.should.have.been.calledOnce
        consoleLogSpy.should.have.been.calledWithExactly CONSOLE_MSG
        protocolSendStub.should.have.been.calledOnce
        protocolSendStub.should.have.been.calledWithExactly RECORD
        createDiagServiceMessageStub.should.have.been.calledOnce
        createDiagServiceMessageStub.should.have.been.calledWithExactly LEVEL, ARGS
        createConsoleLogMessageStub.should.have.been.calledOnce
        createConsoleLogMessageStub.should.have.been.calledWithExactly ARGS

    it "should log the message to the console when sending diag message failed", ->
        LEVEL = "loglevel"
        ARGS = "args"
        LOG_MSG = "logmsg"
        CONSOLE_MSG = LEVEL + ": " + LOG_MSG
        RECORD = "RECORD"

        consoleLogSpy = sandbox.spy console, "log"
        createDiagServiceMessageStub = sandbox.stub Diag, "_createDiagServiceMessage"
        createDiagServiceMessageStub.returns RECORD
        createConsoleLogMessageStub = sandbox.stub Diag, "_createConsoleLogMessage"
        protocolSendStub = sandbox.stub Protocol, "sendDiag"
        protocolSendStub.returns false
        createConsoleLogMessageStub.returns LOG_MSG

        Diag.log LEVEL, ARGS

        consoleLogSpy.should.have.been.calledOnce
        consoleLogSpy.should.have.been.calledWithExactly CONSOLE_MSG
        protocolSendStub.should.have.been.calledOnce
        protocolSendStub.should.have.been.calledWithExactly RECORD
        createDiagServiceMessageStub.should.have.been.calledOnce
        createDiagServiceMessageStub.should.have.been.calledWithExactly LEVEL, ARGS
        createConsoleLogMessageStub.should.have.been.calledOnce
        createConsoleLogMessageStub.should.have.been.calledWithExactly ARGS

    it "shouldn't log the message to the console when flag is switched off and diag message sending was successful", ->
        LEVEL = "loglevel"
        ARGS = "args"
        LOG_MSG = "logmsg"
        CONSOLE_MSG = LEVEL + ": " + LOG_MSG
        RECORD = "RECORD"

        consoleLogSpy = sandbox.spy console, "log"
        createDiagServiceMessageStub = sandbox.stub Diag, "_createDiagServiceMessage"
        createDiagServiceMessageStub.returns RECORD
        createConsoleLogMessageStub = sandbox.stub Diag, "_createConsoleLogMessage"
        protocolSendStub = sandbox.stub Protocol, "sendDiag"
        protocolSendStub.returns true
        createConsoleLogMessageStub.returns LOG_MSG

        Diag.log LEVEL, ARGS

        consoleLogSpy.should.not.have.been.calledOnce
        protocolSendStub.should.have.been.calledOnce
        protocolSendStub.should.have.been.calledWithExactly RECORD
        createDiagServiceMessageStub.should.have.been.calledOnce
        createDiagServiceMessageStub.should.have.been.calledWithExactly LEVEL, ARGS
        createConsoleLogMessageStub.should.not.have.been.calledOnce

    it "should clear the new symbols and new headers if sending was successful", ->
        LEVEL = "loglevel"
        ARGS = ["arg1"]

        createDiagServiceMessageStub = sandbox.stub Diag, "_createDiagServiceMessage"
        createConsoleLogMessageStub = sandbox.stub Diag, "_createConsoleLogMessage"
        protocolSendStub = sandbox.stub Protocol, "sendDiag"
        protocolSendStub.returns true
        clearSentHeadersAndSymbolsStub = sandbox.stub Diag, "_clearSentHeadersAndSymbols"

        Diag.log LEVEL, ARGS

        clearSentHeadersAndSymbolsStub.should.have.been.calledOnce

    it "should not clear the new symbols and new headers if sending failed", ->
        LEVEL = "loglevel"
        ARGS = ["arg1"]

        createDiagServiceMessageStub = sandbox.stub Diag, "_createDiagServiceMessage"
        createConsoleLogMessageStub = sandbox.stub Diag, "_createConsoleLogMessage"
        protocolSendStub = sandbox.stub Protocol, "sendDiag"
        protocolSendStub.returns false
        clearSentHeadersAndSymbolsStub = sandbox.stub Diag, "_clearSentHeadersAndSymbols"

        Diag.log LEVEL, ARGS

        clearSentHeadersAndSymbolsStub.should.not.have.been.calledOnce


describe "Diag _createConsoleLogMessage", ->

    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        sandbox.restore()

    it "should display simple text message", ->
        MSG1 = "MSG1"

        consoleMessage = Diag._createConsoleLogMessage [MSG1]
        consoleMessage.should.be.deep.equal MSG1

    it "should display multiple text message", ->
        MSG1 = "MSG1"
        MSG2 = "MSG2"
        MSG_COMP = MSG1 + " " + MSG2

        consoleMessage = Diag._createConsoleLogMessage [MSG1, MSG2]
        consoleMessage.should.be.deep.equal MSG_COMP

    it "should display simple variable content", ->
        OBJ1 = "OBJ1"
        obj1 = new Object
        obj1ToString = sandbox.stub obj1, "toString"
        obj1ToString.returns OBJ1

        consoleMessage = Diag._createConsoleLogMessage [obj1]
        consoleMessage.should.be.deep.equal OBJ1

    it "should display multiple variable content", ->
        OBJ1 = "OBJ1"
        obj1 = new Object
        obj1ToString = sandbox.stub obj1, "toString"
        obj1ToString.returns OBJ1
        OBJ2 = "OBJ2"
        obj2 = new Object
        obj2ToString = sandbox.stub obj2, "toString"
        obj2ToString.returns OBJ2
        MSG_COMP = OBJ1 + " " + OBJ2

        consoleMessage = Diag._createConsoleLogMessage [obj1, obj2]
        consoleMessage.should.be.deep.equal MSG_COMP

    it "should display text and variable content", ->
        OBJ1 = "OBJ1"
        obj1 = new Object
        obj1ToString = sandbox.stub obj1, "toString"
        obj1ToString.returns OBJ1
        MSG1 = "MSG1"
        MSG_COMP = OBJ1 + " " + MSG1
        consoleMessage = Diag._createConsoleLogMessage [obj1, MSG1]
        consoleMessage.should.be.deep.equal MSG_COMP


describe "Diag _createDiagServiceMessage", ->
    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        sandbox.restore()

    it "should display simple text message", ->
        text = "MSG1"

        message = Diag._createDiagServiceMessage 'VIRTDB_SIMPLE_TRACE', [text]
        message.Process.StartDate.should.be.greaterThan('20150101')
        message.Process.StartDate.should.be.lessThan('21150101')
        message.Process.StartTime.should.be.greaterThan('000000')
        message.Process.StartTime.should.be.lessThan('235959')
        message.Process.Pid.should.be.greaterThan(0)
        message.Process.Random.should.be.greaterThan(0)
        message.Process.NameSymbol.should.be.lessThan(10)
        message.Process.HostSymbol.should.be.lessThan(10)
        message.Data.length.should.equal(1)
        message.Data[0].HeaderSeqNo.should.be.lessThan(10)
        message.Data[0].ThreadId.should.equal(0)
        message.Data[0].Values.length.should.equal(0)
        message.Symbols.length.should.equal(5)
        message.Symbols[4].Value.should.equal(text)
        message.Headers[0].SeqNo.should.equal(0)
        message.Headers[0].FileNameSymbol.should.be.lessThan(10)
        message.Headers[0].FunctionNameSymbol.should.be.lessThan(10)
        message.Headers[0].Level.should.equal('VIRTDB_SIMPLE_TRACE')
        message.Headers[0].LogStringSymbol.should.be.lessThan(10)
        message.Headers[0].Parts.length.should.equal(1)
        message.Headers[0].Parts[0].HasData.should.equal(false)
        message.Headers[0].Parts[0].IsVariable.should.equal(false)
        message.Headers[0].Parts[0].PartSymbol.should.equal(4)
        message.Headers[0].Parts[0].Type.should.equal('STRING')

describe "Diag _getProcessInfo", ->
    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        sandbox.restore()

    it "should set good hostname and component name", ->
        HOSTNAME = "host"
        COMPNAME = "comp"

        hostnameStub = sandbox.stub os, "hostname"
        hostnameStub.returns HOSTNAME
        Diag.componentName = COMPNAME
        getSeqStub = sandbox.stub Diag, "_getSymbolSeqNo"
        getSeqStub.onFirstCall().returns 1
        getSeqStub.onSecondCall().returns 2

        process = Diag._getProcessInfo()

        getSeqStub.getCall(0).should.have.been.calledWithExactly COMPNAME
        getSeqStub.getCall(1).should.have.been.calledWithExactly HOSTNAME
        process.should.have.deep.property "NameSymbol", 1
        process.should.have.deep.property "HostSymbol", 2
