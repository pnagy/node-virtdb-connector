EndpointHandler = require "../endpointHandler"
protobuf    = require 'virtdb-proto'
zmq     = require 'zmq'

chai = require "chai"
chai.should()

sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

class SocketStub
    callback: null
    on: (message, @callback) =>

describe "EndpointHandler", ->
    sandbox = null
    socket = null
    url = "tcp://192.168.221.11:12345"

    beforeEach =>
        sandbox = sinon.sandbox.create()
        socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) ->
            type.should.equal 'req'
            return socket
        socket.connect = sandbox.spy()
        socket.send = sandbox.spy()
        sandbox.spy(socket, 'on')

    afterEach =>
        sandbox.restore()

    it "should connect to endpoint service", ->
        handler = new EndpointHandler()
        handler.connect(url)
        socket.connect.should.have.been.calledWith url
        socket.on.should.have.been.called.once

    it "should survive empty messages", ->
        handler = new EndpointHandler()
        handler.connect(url)
        endpoint = {}
        socket.callback protobuf.service_config.serialize endpoint, "virtdb.interface.pb.Endpoint"

    it "should report single message", ->
        callback = sandbox.spy()
        handler = new EndpointHandler()
        handler.on 'QUERY', 'PUSH_PULL', callback
        handler.connect url
        endpoint =
            Endpoints: [
                Name: "name"
                SvcType: "QUERY"
                Connections: [
                    Type: 'PUSH_PULL'
                    Address: [
                        'tcp://localhost:12345'
                    ]
                ]
            ]
        socket.callback protobuf.service_config.serialize endpoint, "virtdb.interface.pb.Endpoint"
        callback.should.have.been.called.once

    it "should not crash when there is no handler for the given endpoint", ->
        handler = new EndpointHandler()
        handler.connect url
        endpoint =
            Endpoints: [
                Name: "name"
                SvcType: "QUERY"
                Connections: [
                    Type: 'PUSH_PULL'
                    Address: [
                        'tcp://localhost:12345'
                    ]
                ]
            ]
        socket.callback.should.not.throw
        socket.callback protobuf.service_config.serialize endpoint, "virtdb.interface.pb.Endpoint"

    it "should report multiple messages", ->
        callback = sandbox.spy()
        handler = new EndpointHandler()
        handler.on 'QUERY', 'PUSH_PULL', callback
        handler.on 'COLUMN', 'PUB_SUB', callback
        handler.connect url
        endpoint =
            Endpoints: [
                Name: "name"
                SvcType: "QUERY"
                Connections: [
                    Type: 'PUSH_PULL'
                    Address: [
                        'tcp://localhost:12345'
                    ]
                ]
            ,
                Name: "name"
                SvcType: "COLUMN"
                Connections: [
                    Type: 'PUB_SUB'
                    Address: [
                        'tcp://localhost:12346'
                    ]
                ]
            ]
        socket.callback protobuf.service_config.serialize endpoint, "virtdb.interface.pb.Endpoint"
        callback.should.have.been.called.twice

    it "should send endpoint messages", ->
        endpoint =
            Endpoints: [
                Name: "name"
                SvcType: "QUERY"
            ]
        handler = new EndpointHandler()
        handler.connect url
        handler.send endpoint
        socket.send.should.have.been.called.once
