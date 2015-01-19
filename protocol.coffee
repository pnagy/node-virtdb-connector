fs          = require 'fs'
zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'

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

    @bindHandler: (socket, svcType, zmqType, onBound) ->
        return (err) ->
            zmqAddress = ""
            if not err
                zmqAddress = socket.getsockopt zmq.ZMQ_LAST_ENDPOINT
            onBound err, svcType, zmqType, zmqAddress

    @sendDiag: (logRecord) =>
        try
            @diag_socket.send proto_diag.serialize logRecord, "virtdb.interface.pb.LogRecord"
        catch ex
            console.error "Couldn't send log message: ", ex
            return false
        return true

    @connectToDiag: (addresses) =>
        ret = null
        connected = false
        for address in addresses
            if not @diag_socket?
                @diag_socket = zmq.socket "push"
            @diag_socket.connect address

    @close: () =>
        @diag_socket?.close()
        @diagAddress = null


module.exports = Protocol
