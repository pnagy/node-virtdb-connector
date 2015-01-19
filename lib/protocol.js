var EndpointHandler, Protocol, fs, proto_diag, proto_service_config, protobuf, zmq,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

zmq = require('zmq');

protobuf = require('virtdb-proto');

proto_service_config = protobuf.service_config;

proto_diag = protobuf.diag;

EndpointHandler = (function() {
  var svcConfigSocket;

  svcConfigSocket = null;

  function EndpointHandler(connectionString, onEndpoint) {
    this.close = __bind(this.close, this);
    this.send = __bind(this.send, this);
    this.svcConfigSocket = zmq.socket('req');
    this.svcConfigSocket.on('message', function(message) {
      var endpoint, endpointMessage, ex, _i, _len, _ref, _results;
      try {
        endpointMessage = proto_service_config.parse(message, 'virtdb.interface.pb.Endpoint');
        _ref = endpointMessage.Endpoints;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          endpoint = _ref[_i];
          _results.push(onEndpoint(endpoint));
        }
        return _results;
      } catch (_error) {
        ex = _error;
        return console.log(ex);
      }
    });
    this.svcConfigSocket.connect(connectionString);
  }

  EndpointHandler.prototype.send = function(endpoint) {
    return this.svcConfigSocket.send(proto_service_config.serialize(endpoint, 'virtdb.interface.pb.Endpoint'));
  };

  EndpointHandler.prototype.close = function() {
    return this.svcConfigSocket.close();
  };

  return EndpointHandler;

})();

Protocol = (function() {
  function Protocol() {}

  Protocol.EndpointHandler = EndpointHandler;

  Protocol.diag_socket = null;

  Protocol.diagAddress = null;

  Protocol.bindHandler = function(socket, svcType, zmqType, onBound) {
    return function(err) {
      var zmqAddress;
      zmqAddress = "";
      if (!err) {
        zmqAddress = socket.getsockopt(zmq.ZMQ_LAST_ENDPOINT);
      }
      return onBound(err, svcType, zmqType, zmqAddress);
    };
  };

  Protocol.sendDiag = function(logRecord) {
    var ex;
    try {
      Protocol.diag_socket.send(proto_diag.serialize(logRecord, "virtdb.interface.pb.LogRecord"));
    } catch (_error) {
      ex = _error;
      return false;
    }
    return true;
  };

  Protocol.connectToDiag = function(addresses) {
    var address, connected, ret, _i, _len, _results;
    ret = null;
    connected = false;
    _results = [];
    for (_i = 0, _len = addresses.length; _i < _len; _i++) {
      address = addresses[_i];
      if (Protocol.diag_socket == null) {
        Protocol.diag_socket = zmq.socket("push");
      }
      _results.push(Protocol.diag_socket.connect(address));
    }
    return _results;
  };

  Protocol.close = function() {
    var _ref;
    if ((_ref = Protocol.diag_socket) != null) {
      _ref.close();
    }
    return Protocol.diagAddress = null;
  };

  return Protocol;

})();

module.exports = Protocol;

//# sourceMappingURL=protocol.js.map