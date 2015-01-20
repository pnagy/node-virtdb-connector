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
    @Sockets = {}
    @Convert = Convert
    @handler = new EndpointHandler()
    @callbacks = []

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
        @Sockets = {}
        @handler = new EndpointHandler()
        @callbacks = []

    @onAddress: (service_type, connection_type, callback) =>
        @handler.on service_type, connection_type, callback

    @subscribe: (service_type, callback, channel) =>
        @handler.on service_type, 'PUB_SUB', (name, addresses) =>
            socket = @Sockets?[name]?[service_type]
            socket?.unsubscribe channel
            socket?.close()
            socket ?= zmq.socket 'sub'
            socket.on "message", callback
            for address in addresses
                socket.connect address
            channel ?= ""
            socket.subscribe channel
            @Sockets[name] ?= {}
            @Sockets[name][service_type] = socket

    @setupEndpoint: (name, protocol_call, callback) =>
        onBound = (name, socket, svcType, zmqType) =>
            return (err) =>
                if err
                    log.error "Error during binding socket: " + err
                    return
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
