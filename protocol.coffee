zmq         = require 'zmq'
protobuf    = require 'virtdb-proto'
proto_diag           = protobuf.diag

class Protocol
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
            return false
        return true

    @connectToDiag: (addresses) =>
        ret = null
        connected = false
        if addresses
            for address in addresses
                if not @diag_socket?
                    @diag_socket = zmq.socket "push"
                @diag_socket.connect address

    @close: () =>
        @diag_socket?.close()
        @diag_socket = null
        @diagAddress = null


module.exports = Protocol
