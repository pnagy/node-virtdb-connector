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
    constructor: ->
        @connect = sinon.spy()
        @send = sinon.spy()
        @close = sinon.spy()
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
    udp_socket = null

    beforeEach =>
        sandbox = sinon.sandbox.create()
        req_socket = new SocketStub
        connectStub = sandbox.stub zmq, "socket", (type) =>
            if type is 'req'
                return req_socket
            else
                return null
        udp_socket = new UDPSocketStub
        udpStub = sandbox.stub udp, "createSocket", (type) =>
            return udp_socket

    afterEach =>
        sandbox.restore()
        VirtDBConnector.close()

    it "should be able to connect to config service", ->
        VirtDBConnector.connect "node-connector-test", "localhost"
        req_socket.connect.should.have.been.calledWith "localhost"
        endpoint =
            Endpoints: [
                Name: "node-connector-test"
                SvcType: 'NONE'
            ]
        endpointSerialized = proto_service_config.serialize endpoint ,'virtdb.interface.pb.Endpoint'
        req_socket.send.should.have.been.calledWith endpointSerialized

    detectIP = ->
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
        ip = "tcp://127.0.0.1:54321"
        udp_socket.send.should.have.been.called
        udp_socket.callback ip
        udp_socket.close.should.have.been.called
        VirtDBConnector.IP.should.equal ip

    it "should detect its own IP", ->
        VirtDBConnector.connect "node-connector-test", "localhost"
        detectIP()

    it "should perform the callback when IP is detected", ->
        cb = sinon.spy()
        VirtDBConnector.onIP cb
        VirtDBConnector.connect "node-connector-test", "localhost"
        detectIP()
        cb.should.have.been.called
