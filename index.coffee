udp         = require 'dgram'
Protocol    = require './protocol'
EndpointHandler = require './endpointHandler'
log         = require './log'
zmq         = require 'zmq'
Constants   = require './constants'
Convert     = require './convert'

class VirtDBConnector
    # types
    @FieldData = require "./fieldData"

    # members

    @IP: null
    @log = log
    @Constants = Constants
    @Sockets = {}
    @Convert = Convert
    @handler = new EndpointHandler()
    @callbacks = []
    @PubSubCallbacks = null

    @connect: (name, connectionString) =>
        @handler.on 'IP_DISCOVERY', 'RAW_UDP', (name, addresses) =>
            @_findMyIP addresses[0] # TODO should we handle more addresses here?
        @handler.on 'LOG_RECORD', 'PUSH_PULL', (name, addresses) =>
            Protocol.connectToDiag addresses
        @subscribe 'ENDPOINT', @handler.onEndpoint
        @handler.connect connectionString
        log.setComponentName name

        endpoint =
            Endpoints: [
                Name: name
                SvcType: 'NONE'
            ]
        @handler.send endpoint

    @close: =>
        @handler?.close()
        @IP = null
        for endpoint_name of @Sockets
            for service_type of @Sockets[endpoint_name]
                @Sockets[endpoint_name][service_type].close()
        @Sockets = {}
        @handler = new EndpointHandler()
        @callbacks = []
        Protocol?.close()
        @PubSubCallbacks = null

    @onAddress: (service_type, connection_type, callback) =>
        @handler.on service_type, connection_type, callback

    @subscribe: (service_type, callback, channel) =>
        @PubSubCallbacks ?= {}
        @PubSubCallbacks[service_type] ?= []
        @PubSubCallbacks[service_type].push callback
        @handler.on service_type, 'PUB_SUB', (name, addresses) =>
            socket = @Sockets?[name]?[service_type]
            socket ?= zmq.socket 'sub'
            socket.on "message", (channel, message) =>
                for callback in @PubSubCallbacks[service_type]
                    callback channel, message
            for address in addresses
                socket.connect address
            channel ?= ""
            socket.subscribe channel
            @Sockets[name] ?= {}
            @Sockets[name][service_type] = socket

    @setupEndpoint: (name, protocol_call, callback) =>
        onBound = (name, socket, svcType, zmqType) =>
            return () =>
                zmqAddress = socket.getsockopt zmq.ZMQ_LAST_ENDPOINT
                log.info "Listening (" + svcType + ") on", zmqAddress
                endpoint =
                    Endpoints: [
                        Name: name
                        SvcType: svcType
                        Connections: [
                            Type: zmqType
                            Address: [
                                zmqAddress
                            ]
                        ]
                    ]
                @handler.send endpoint

        if @IP?
            log.info "Our IP:", @IP
            protocol_call name, 'tcp://' + @IP + ':*', callback, onBound
        else
            @callbacks.push () =>
                protocol_call name, 'tcp://' + @IP + ':*', callback, onBound
        return

    @_findMyIP: (discoveryAddress) =>
        if discoveryAddress.indexOf 'raw_udp://' == 0
            client = null
            address = discoveryAddress.replace /^raw_udp:\/\//, ''
            if address.indexOf('[') > -1 # IPv6
                ip = address.replace /^\[|\]:[0-9]{2,5}/g, ''
                port = address.replace /\[.*\]:/g, ''
                client = udp.createSocket 'udp6'
            else    # IPv4
                parts = address.split(':')
                ip = parts[0]
                port = parts[1]
                client = udp.createSocket 'udp4'

            client?.on 'message', (message, remote) =>
                @IP = message.toString()
                for callback in @callbacks
                    callback()
                @callbacks = []
                client.close()

            wait_for_ip = (client, port, ip) =>
                if @IP?
                    return
                else
                    try
                        message = new Buffer('?')
                        client?.send  message, 0, 1, port, ip, (err, bytes) ->
                            if err
                                log.error err
                    catch ex
                        log.error ex
                    setTimeout wait_for_ip, 10, client, port, ip

            wait_for_ip client, port, ip

module.exports = VirtDBConnector
