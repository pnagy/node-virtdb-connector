zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'
proto_service_config = protobuf.service_config

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

module.exports = EndpointHandler
