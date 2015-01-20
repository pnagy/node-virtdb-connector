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
            try
                endpointMessage = proto_service_config.parse message, 'virtdb.interface.pb.Endpoint'
                for endpoint in endpointMessage.Endpoints
                    @onEndpoint endpoint
            catch ex
                log.error ex
        @svcConfigSocket.connect connectionString

    send: (endpoint) =>
        @svcConfigSocket.send proto_service_config.serialize endpoint, 'virtdb.interface.pb.Endpoint'

    close: () =>
        @svcConfigSocket.close()
        @Handlers = {}

    on: (service_type, connection_type, callback) =>
        @Handlers[service_type] ?= {}
        @Handlers[service_type][connection_type] = callback

    onEndpoint: (endpoint) =>
        if endpoint.Connections?
            for connection in endpoint.Connections
                @Handlers?[endpoint.SvcType]?[connection.Type]? endpoint.Name, connection.Address

module.exports = EndpointHandler
