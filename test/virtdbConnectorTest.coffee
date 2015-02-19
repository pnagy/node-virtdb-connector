VirtDBConnector = require '../index'

zmq = require "zmq"
protobuf    = require 'virtdb-proto'
proto_service_config = protobuf.service_config
udp         = require 'dgram'

chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

class SocketStub
    callback: null
    # bound: false
    # sent: false
    connect: null
    send: null
    close: null
    subscribe: null
    constructor: ->
        @connect = sinon.spy()
        @send = sinon.spy()
        @close = sinon.spy()
        @subscribe = sinon.spy()
    on: (message, @callback) =>
    # bind: (address, callback) =>
    #     @bound = true
    #     callback()
    # close: () =>
    # send: (data) =>
    #     @sent = true

class UDPSocketStub
    callback: null
    close: null
    send: null

    constructor: ->
        @send = sinon.spy()
        @close = sinon.spy()
    on: (message, @callback) =>

describe "VirtDBConnector", ->
    sandbox = null
    req_socket = null
    sub_socket = null
    push_socket = null
    udp_socket = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        req_socket = new SocketStub
        sub_socket = new SocketStub
        push_socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) =>
            if type is 'req'
                return req_socket
            if type is 'sub'
                return sub_socket
            if type is 'push'
                return push_socket
            else
                return null
        udp_socket = new UDPSocketStub
        udpStub = sandbox.stub udp, "createSocket", (type) =>
            return udp_socket

    afterEach =>
        sandbox.restore()
        VirtDBConnector.close()

    it "should be able to connect to config service", ->
        NAME = "node-connector-test"
        VirtDBConnector.connect NAME, "localhost"
        req_socket.connect.should.have.been.calledWith "localhost"
        endpoint =
            Endpoints: [
                Name: "node-connector-test"
                SvcType: 'NONE'
            ]
        endpointSerialized = proto_service_config.serialize endpoint ,'virtdb.interface.pb.Endpoint'
        req_socket.send.should.have.been.calledWith endpointSerialized

    it "should close all open sockets on closing", ->
        NAME = "node-connector-test"
        cb = sandbox.spy()
        VirtDBConnector.subscribe 'META_DATA', cb
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "diag-service"
                SvcType: 'LOG_RECORD'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.0.0.1:12347"
                    ]
                ]
        ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)

        message =
            Endpoints: [
                Name: "fictional-provider"
                SvcType: 'META_DATA'
                Connections: [
                    Type: "PUB_SUB"
                    Address: [
                        "tcp://127.0.0.1:12348"
                    ]
                ]
        ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        VirtDBConnector.close()
        req_socket.close.should.have.been.called
        sub_socket.connect.should.have.been.called
        sub_socket.close.should.have.been.called
        push_socket.connect.should.have.been.called
        push_socket.close.should.have.been.called


    it "should set the name of the component to the log", ->
        NAME = "node-connector-test"
        setCompNameStub = sandbox.stub VirtDBConnector.log, "setComponentName"

        VirtDBConnector.connect NAME, "localhost"
        setCompNameStub.should.have.been.calledOnce
        setCompNameStub.should.have.been.calledWithExactly NAME

    detectIP = (done) ->
        message =
            Endpoints: [
                Name: "discovery"
                SvcType: 'IP_DISCOVERY'
                Connections: [
                    Type: "RAW_UDP"
                    Address: [
                        "raw_udp://127.0.0.1:12345"
                    ]
                ]
        ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        ip = "127.0.0.1"
        udp_socket.send.should.have.been.called
        setTimeout () ->
            udp_socket.callback ip
            setTimeout () ->
                udp_socket.close.should.have.been.called
                VirtDBConnector.IP.should.equal ip
                if (done?)
                    done()
            , 100
        , 200

    it "should detect its own IP", (done) ->
        this.timeout(400)
        VirtDBConnector.connect "node-connector-test", "localhost"
        detectIP(done)

    it "should perform the callback when IP is detected", (done) ->
        this.timeout(500)
        cb = sandbox.spy()
        VirtDBConnector.setupEndpoint "test", cb
        VirtDBConnector.connect "node-connector-test", "localhost"
        detectIP()
        setTimeout () ->
            cb.should.have.been.called
            done()
        , 400

    it "should be able to set up endpoints", (done) ->
        this.timeout(500)
        cb = sandbox.spy()
        protocol_call = sandbox.spy()
        VirtDBConnector.setupEndpoint "test", protocol_call, cb
        VirtDBConnector.connect "node-connector-test", "localhost"
        detectIP()
        setTimeout () ->
            protocol_call.should.have.been.calledWith('test', 'tcp://127.0.0.1:*')
            done()
        , 400

    it "should call the registered callback handlers when a given endpoint is received on req_rep socket", ->
        cb1 = sandbox.spy()
        cb2 = sandbox.spy()
        NAME = "node-connector-test"
        VirtDBConnector.onAddress 'QUERY', 'PUSH_PULL', cb1
        VirtDBConnector.onAddress 'QUERY', 'PUSH_PULL', cb2
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "test"
                SvcType: 'QUERY'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.0.0.1:12345"
                    ]
                ]
        ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        cb1.should.have.been.called
        cb2.should.have.been.called

    it "should call the callback handlers registered for all socket type when a given endpoint is received on req_rep socket", ->
        cb1 = sandbox.spy()
        NAME = "node-connector-test"
        VirtDBConnector.onAddress VirtDBConnector.ALL_TYPE, 'PUSH_PULL', cb1
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "test1"
                SvcType: 'QUERY'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.0.0.1:12345"
                    ]
                ]
            ,
                Name: "test2"
                SvcType: 'LOG_RECORD'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.0.0.1:134343445"
                    ]
                ]
            ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        cb1.should.have.been.calledTwice

    it "should call the callback handlers registered for all connection type when a given endpoint is received on req_rep socket", ->
        cb1 = sandbox.spy()
        NAME = "node-connector-test"
        VirtDBConnector.onAddress 'QUERY', VirtDBConnector.ALL_TYPE, cb1
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "test1"
                SvcType: 'QUERY'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.0.0.1:12345"
                    ]
                ]
            ,
                Name: "test2"
                SvcType: 'QUERY'
                Connections: [
                    Type: "REQ_REP"
                    Address: [
                        "tcp://127.0.0.1:657575"
                    ]
                ]
            ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        cb1.should.have.been.calledTwice

    it "should call the callback handlers registered for all endpoint when a given endpoint is received on req_rep socket", ->
        cb1 = sandbox.spy()
        NAME = "node-connector-test"
        VirtDBConnector.onAddress VirtDBConnector.ALL_TYPE, VirtDBConnector.ALL_TYPE, cb1
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "test1"
                SvcType: 'QUERY'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.0.0.1:12345"
                    ]
                ]
            ,
                Name: "test2"
                SvcType: 'LOG_RECORD'
                Connections: [
                    Type: "REQ_REP"
                    Address: [
                        "tcp://127.0.0.1:657575"
                    ]
                ]
            ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        cb1.should.have.been.calledTwice

    it "should not call the registered callback handler when a different endpoint is received on req_rep socket", ->
        cb = sandbox.spy()
        NAME = "node-connector-test"
        VirtDBConnector.onAddress 'QUERY', 'PUSH_PULL', cb
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "test"
                SvcType: 'COLUMN'
                Connections: [
                    Type: "PUB_SUB"
                    Address: [
                        "tcp://127.0.0.1:12345"
                    ]
                ]
        ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        cb.should.have.not.been.called

    it "should call the registered callbacks subscribed to a PUB_SUB endpoint", ->
        cb1 = sandbox.spy()
        cb2 = sandbox.spy()
        NAME = "node-connector-test"
        VirtDBConnector.subscribe 'COLUMN', cb1
        VirtDBConnector.subscribe 'COLUMN', cb2
        VirtDBConnector.connect NAME, "localhost"
        message =
            Endpoints: [
                Name: "test"
                SvcType: 'COLUMN'
                Connections: [
                    Type: "PUB_SUB"
                    Address: [
                        "tcp://127.0.0.1:12345"
                    ]
                ]
        ]
        messageSerialized = proto_service_config.serialize message, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(messageSerialized)
        sub_socket.subscribe.should.have.been.calledWith('')
        sub_socket.callback('channelid', 'message')
        cb1.should.have.been.calledWith('channelid', 'message')
        cb2.should.have.been.calledWith('channelid', 'message')

    it "should be able to be closed without connecting", ->
        VirtDBConnector.close.should.not.throw
        VirtDBConnector.close()

    it "should call the registered callback handlers when a given endpoint is received on pub_sub socket", ->
        NAME = "node-connector-test"
        cb = sandbox.spy()
        VirtDBConnector.onAddress 'QUERY', 'PUSH_PULL', cb
        VirtDBConnector.connect NAME, "localhost"
        endointsSubMsg =
            Endpoints: [
                Name: "cfgSvcTest"
                SvcType: 'ENDPOINT'
                Connections: [
                    Type: "PUB_SUB"
                    Address: [
                        "tcp://127.0.089.1:12345"
                    ]
                ]
        ]
        newEndpoint =
            Endpoints: [
                Name: "newpublishedtest"
                SvcType: 'QUERY'
                Connections: [
                    Type: "PUSH_PULL"
                    Address: [
                        "tcp://127.78.89.1:12345"
                    ]
                ]
        ]
        endointsSubMsgSerialized = proto_service_config.serialize endointsSubMsg, 'virtdb.interface.pb.Endpoint'
        newEndpointSerialized = proto_service_config.serialize newEndpoint, 'virtdb.interface.pb.Endpoint'
        req_socket.callback(endointsSubMsgSerialized)
        sub_socket.callback('channelid', newEndpointSerialized)
        sub_socket.subscribe.should.have.been.called
        cb.should.have.been.called

    it "should subscribe for endpoints", ->
        NAME = "node-connector-test"
        subSpy = sandbox.stub VirtDBConnector, "subscribe"
        VirtDBConnector.connect NAME, "localhost"
        subSpy.should.have.been.calledWith "ENDPOINT"
