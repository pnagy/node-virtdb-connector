Protocol = require "../protocol"
# protobuf    = require 'virtdb-proto'
zmq     = require 'zmq'

chai = require "chai"
chai.should()

sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

class SocketStub
    callback: null
    on: (message, @callback) =>

describe "Protocol", ->
    sandbox = null
    socket = null
    # url = "tcp://192.168.221.11:12345"

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket"
        connectStub.withArgs('push').onCall(0).returns(socket)
        connectStub.throws()
        socket.connect = sandbox.spy()
        socket.close = sandbox.spy()
        # socket.send = sandbox.spy()
        # sandbox.spy(socket, 'on')

    afterEach =>
        sandbox.restore()
        Protocol.close()

    it "should not fail if not getting addresses", ->
        Protocol.connectToDiag.should.not.throw
        # handler = new EndpointHandler url, () ->
        # socket.connect.should.have.been.calledWith url
        # socket.on.should.have.been.called.once

    it "should be able to connect", ->
        addresses = [
            "tcp://192.168.0.1:12345"
            "tcp://192.168.1.1:12345"
            "tcp://localhost:12345"
        ]
        Protocol.connectToDiag addresses
        socket.connect.should.have.callCount(addresses.length)
