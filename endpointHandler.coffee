zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'
proto_service_config = protobuf.service_config
log         = require './log'

class EndpointHandler

    @ALL_TYPE = "*"

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
                for handler in @_getMatchingHandlers endpoint.SvcType, connection.Type
                    handler endpoint.Name, connection.Address, endpoint.SvcType, connection.Type

    _getMatchingHandlers: (svcType, connectionType) =>
        handlers = []
        if @Handlers?[EndpointHandler.ALL_TYPE]?[EndpointHandler.ALL_TYPE]?
            for handler in @Handlers?[EndpointHandler.ALL_TYPE]?[EndpointHandler.ALL_TYPE]
                handlers.push handler
        if @Handlers?[svcType]?[EndpointHandler.ALL_TYPE]?
            for handler in @Handlers?[svcType]?[EndpointHandler.ALL_TYPE]
                handlers.push handler
        if @Handlers?[EndpointHandler.ALL_TYPE]?[connectionType]?
            for handler in @Handlers?[EndpointHandler.ALL_TYPE]?[connectionType]
                handlers.push handler
        if @Handlers?[svcType]?[connectionType]?
            for handler in @Handlers?[svcType]?[connectionType]
                handlers.push handler
        return handlers

module.exports = EndpointHandler
