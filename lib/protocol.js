var Protocol, proto_diag, protobuf, zmq;

zmq = require('zmq');

protobuf = require('virtdb-proto');

proto_diag = protobuf.diag;

Protocol = (function() {
  function Protocol() {}

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
    if (addresses) {
      _results = [];
      for (_i = 0, _len = addresses.length; _i < _len; _i++) {
        address = addresses[_i];
        if (Protocol.diag_socket == null) {
          Protocol.diag_socket = zmq.socket("push");
        }
        _results.push(Protocol.diag_socket.connect(address));
      }
      return _results;
    }
  };

  Protocol.close = function() {
    var _ref;
    if ((_ref = Protocol.diag_socket) != null) {
      _ref.close();
    }
    Protocol.diag_socket = null;
    return Protocol.diagAddress = null;
  };

  return Protocol;

})();

module.exports = Protocol;

//# sourceMappingURL=protocol.js.map