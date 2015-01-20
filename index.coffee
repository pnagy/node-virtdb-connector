udp         = require 'dgram'
Protocol    = require './protocol'
EndpointHandler = require './endpointHandler'
log         = require './log'
zmq         = require 'zmq'
Constants   = require './constants'
Convert     = require './convert'

class VirtDBConnector
    @IP: null
    @log = log
    @Constants = Constants
    @Handlers = {}
    @Sockets = {}
    @Convert = Convert
    @handler = null
    @callbacks = []

    @connect: (name, connectionString) =>
        @handler = new EndpointHandler connectionString, @_onEndpoint
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
        @Handlers = {}
        @Sockets = {}
        @handler = null
        @callbacks = []

    @onAddress: (service_type, connection_type, callback) =>
        @Handlers[service_type] ?= {}
        @Handlers[service_type][connection_type] = callback

    @subscribe: (service_type, connection_type, callback, channel) =>
        @onAddress service_type, connection_type, (name, address) =>
            if connection_type == 'PUB_SUB'
                socket_type = 'sub'
            if @Sockets?[name]?[service_type]?[connection_type]?
                @Sockets[name][service_type][connection_type].unsubscribe channel
                @Sockets[name][service_type][connection_type].close()
                @Sockets[name][service_type][connection_type] = null

            @Sockets[name] ?= {}
            @Sockets[name][service_type] ?= {}
            @Sockets[name][service_type][connection_type] = zmq.socket socket_type
            socket = @Sockets[name][service_type][connection_type]
            socket.on "message", callback
            socket.connect address
            if connection_type == 'PUB_SUB' and channel?
                socket.subscribe channel

    @onIP: (callback) =>
        if @IP?
            console.log "Our IP:", @IP
            callback()
        else
            @callbacks.push callback

    @setupEndpoint: (name, protocol_call, callback) =>
        protocol_call name, 'tcp://' + @IP + ':*', callback, @_OnBound
        return

    @_onEndpoint: (endpoint) =>
        switch endpoint.SvcType
            when 'IP_DISCOVERY'
                if not @IP?
                    for connection in endpoint.Connections
                        if connection.Type == 'RAW_UDP'
                            @_findMyIP connection.Address[0] # TODO should we handle more addresses here?
            when 'LOG_RECORD'
                for connection in endpoint.Connections
                    if connection.Type == 'PUSH_PULL'
                        Protocol.connectToDiag connection.Address
            else
                if endpoint.Connections?
                    for connection in endpoint.Connections
                        for address in connection.Address
                            @Handlers?[endpoint.SvcType]?[connection.Type]? endpoint.Name, address


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
                                console.log err
                    catch ex
                        console.log ex
                    setTimeout wait_for_ip, 10, client, port, ip

            wait_for_ip client, port, ip

    @_OnBound: (name, socket, svcType, zmqType) =>
        return (err) =>
            if err
                log.error "Error during binding socket: " + err
                return
            zmqAddress = socket.getsockopt zmq.ZMQ_LAST_ENDPOINT
            console.log "Listening (" + svcType + ") on", zmqAddress
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

module.exports = VirtDBConnector
