log = require "../log"
Diag = require "../diag"

chai = require "chai"
chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

describe "Log", ->

    sandbox = null

    beforeEach =>
        sandbox = sinon.sandbox.create()

    afterEach =>
        log.enableConsoleLog false
        sandbox.restore()

    it "should log trace messages only if level is trace", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        log.setLevel log.Levels.ERROR
        log.trace "test"
        log.setLevel log.Levels.WARN
        log.trace "test"
        log.setLevel log.Levels.INFO
        log.trace "test"
        log.setLevel log.Levels.DEBUG
        log.trace "test"
        diaglog.should.have.not.been.called
        log.setLevel log.Levels.TRACE
        log.trace "test"
        diaglog.should.have.been.calledWith('VIRTDB_SIMPLE_TRACE', ['test'])

    it "should log debug messages only if level is trace or debug", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        log.setLevel log.Levels.ERROR
        log.debug "test"
        log.setLevel log.Levels.WARN
        log.debug "test"
        log.setLevel log.Levels.INFO
        log.debug "test"
        diaglog.should.have.not.been.called
        log.setLevel log.Levels.DEBUG
        log.debug "test"
        diaglog.should.have.been.calledWith('VIRTDB_SIMPLE_TRACE', ['test'])
        log.setLevel log.Levels.TRACE
        log.debug "test"
        diaglog.should.have.been.calledWith('VIRTDB_SIMPLE_TRACE', ['test'])

    it "should log info messages only if level is trace, debug or info", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        log.setLevel log.Levels.ERROR
        log.info "test"
        log.setLevel log.Levels.WARN
        log.info "test"
        diaglog.should.have.not.been.called
        log.setLevel log.Levels.INFO
        log.info "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])
        log.setLevel log.Levels.DEBUG
        log.info "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])
        log.setLevel log.Levels.TRACE
        log.info "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])

    it "should log warn messages only if level is trace, debug, info or warn", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        log.setLevel log.Levels.ERROR
        log.warn "test"
        diaglog.should.have.not.been.called
        log.setLevel log.Levels.WARN
        log.warn "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])
        log.setLevel log.Levels.INFO
        log.warn "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])
        log.setLevel log.Levels.DEBUG
        log.warn "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])
        log.setLevel log.Levels.TRACE
        log.warn "test"
        diaglog.should.have.been.calledWith('VIRTDB_INFO', ['test'])

    it "should always log error messages (*except when loglevel is silent)", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        diaglog.should.have.not.been.called
        log.setLevel log.Levels.ERROR
        log.error "test"
        diaglog.should.have.been.calledWith('VIRTDB_ERROR', ['test'])
        log.setLevel log.Levels.WARN
        log.error "test"
        diaglog.should.have.been.calledWith('VIRTDB_ERROR', ['test'])
        log.setLevel log.Levels.INFO
        log.error "test"
        diaglog.should.have.been.calledWith('VIRTDB_ERROR', ['test'])
        log.setLevel log.Levels.DEBUG
        log.error "test"
        diaglog.should.have.been.calledWith('VIRTDB_ERROR', ['test'])
        log.setLevel log.Levels.TRACE
        log.error "test"
        diaglog.should.have.been.calledWith('VIRTDB_ERROR', ['test'])

    it "should not log anything if loglevel is silent", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        log.disableAll()
        log.error "test"
        log.warn "test"
        log.info "test"
        log.debug "test"
        log.trace "test"
        diaglog.should.have.not.been.called

    it "should log anything if it is explicitly set", ->
        diaglog = sandbox.stub Diag, "log"
        log.enableConsoleLog true
        log.enableAll()
        log.error "test"
        log.warn "test"
        log.info "test"
        log.debug "test"
        log.trace "test"
        diaglog.should.have.callCount(5)
