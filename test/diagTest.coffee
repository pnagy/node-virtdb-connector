Diag = require "../diag"
Protocol = require "../protocol"
util = require "util"

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
