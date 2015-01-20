zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'
proto_service_config = protobuf.service_config
log         = require './log'

class EndpointHandler
    svcConfigSocket = null
    Handlers = null

    constructor: () ->
        @Handlers = {}

    connect: (connectionString) ->
        @svcConfigSocket = zmq.socket 'req'
        @svcConfigSocket.on 'message', (message) =>
            endpointMessage = proto_service_config.parse message, 'virtdb.interface.pb.Endpoint'
            for endpoint in endpointMessage.Endpoints
                @onEndpoint endpoint
        @svcConfigSocket.connect connectionString

    send: (endpoint) =>
        @svcConfigSocket.send proto_service_config.serialize endpoint, 'virtdb.interface.pb.Endpoint'

    close: () =>
        @svcConfigSocket?.close()
        @Handlers = {}

    on: (service_type, connection_type, callback) =>
        @Handlers[service_type] ?= {}
        @Handlers[service_type][connection_type] ?= []
        @Handlers[service_type][connection_type].push callback

    onEndpoint: (endpoint) =>
        if endpoint.Connections?
            for connection in endpoint.Connections
                if @Handlers?[endpoint.SvcType]?[connection.Type]?
                    for callback in @Handlers?[endpoint.SvcType]?[connection.Type]
                        callback endpoint.Name, connection.Address

module.exports = EndpointHandler
