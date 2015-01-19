fs          = require 'fs'
zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'
async       = require "async"

proto_service_config = protobuf.service_config
proto_diag           = protobuf.diag

class EndpointHandler
    svcConfigSocket = null
    constructor: (connectionString, onEndpoint) ->
        @svcConfigSocket = zmq.socket 'req'
        @svcConfigSocket.on 'message', (message) ->
            try
                endpointMessage = proto_service_config.parse message, 'virtdb.interface.pb.Endpoint'
                for endpoint in endpointMessage.Endpoints
                    onEndpoint endpoint
            catch ex
                console.log ex
        @svcConfigSocket.connect connectionString

    send: (endpoint) =>
        @svcConfigSocket.send proto_service_config.serialize endpoint, 'virtdb.interface.pb.Endpoint'

    close: () =>
        @svcConfigSocket.close()

class Protocol
    @EndpointHandler = EndpointHandler
    @diag_socket = null
    @diagAddress = null

    @bindHandler = (socket, svcType, zmqType, onBound) ->
        return (err) ->
            zmqAddress = ""
            if not err
                zmqAddress = socket.getsockopt zmq.ZMQ_LAST_ENDPOINT
            onBound err, svcType, zmqType, zmqAddress

    @sendDiag = (logRecord) =>
        try
            @diag_socket.send proto_diag.serialize logRecord, "virtdb.interface.pb.LogRecord"
        catch ex
            return false
        return true

    @connectToDiag = (addresses) =>
        ret = null
        connected = false
        async.eachSeries addresses, (address, callback) =>
            try
                if ret
                    callback()
                    return
                if address == @diagAddress
                    ret = address
                    callback()
                    return
                socket = zmq.socket "push"
                socket.connect address
                @diagAddress = address
                ret = address
                @diag_socket = socket
                connected = true
                callback()
            catch e
                callback e
        , (err) ->
            return
        if connected
            ret
        else
            null

module.exports = Protocol
