var EndpointHandler, log, proto_service_config, protobuf, zmq,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

zmq = require('zmq');

protobuf = require('virtdb-proto');

proto_service_config = protobuf.service_config;

log = require('./log');

EndpointHandler = (function() {
  var Handlers, svcConfigSocket;

  svcConfigSocket = null;

  Handlers = null;

  function EndpointHandler() {
    this.onEndpoint = __bind(this.onEndpoint, this);
    this.on = __bind(this.on, this);
    this.close = __bind(this.close, this);
    this.send = __bind(this.send, this);
    this.Handlers = {};
  }

  EndpointHandler.prototype.connect = function(connectionString) {
    this.svcConfigSocket = zmq.socket('req');
    this.svcConfigSocket.on('message', (function(_this) {
      return function(message) {
        var endpoint, endpointMessage, ex, _i, _len, _ref, _results;
        try {
          endpointMessage = proto_service_config.parse(message, 'virtdb.interface.pb.Endpoint');
          _ref = endpointMessage.Endpoints;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            endpoint = _ref[_i];
            _results.push(_this.onEndpoint(endpoint));
          }
          return _results;
        } catch (_error) {
          ex = _error;
          return log.error(ex);
        }
      };
    })(this));
    return this.svcConfigSocket.connect(connectionString);
  };

  EndpointHandler.prototype.send = function(endpoint) {
    return this.svcConfigSocket.send(proto_service_config.serialize(endpoint, 'virtdb.interface.pb.Endpoint'));
  };

  EndpointHandler.prototype.close = function() {
    this.svcConfigSocket.close();
    return this.Handlers = {};
  };

  EndpointHandler.prototype.on = function(service_type, connection_type, callback) {
    var _base, _base1;
    if ((_base = this.Handlers)[service_type] == null) {
      _base[service_type] = {};
    }
    if ((_base1 = this.Handlers[service_type])[connection_type] == null) {
      _base1[connection_type] = [];
    }
    return this.Handlers[service_type][connection_type].push(callback);
  };

  EndpointHandler.prototype.onEndpoint = function(endpoint) {
    var callback, connection, _i, _len, _ref, _results;
    if (endpoint.Connections != null) {
      _ref = endpoint.Connections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        connection = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _ref2, _ref3, _results1;
          _ref3 = (_ref1 = this.Handlers) != null ? (_ref2 = _ref1[endpoint.SvcType]) != null ? _ref2[connection.Type] : void 0 : void 0;
          _results1 = [];
          for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
            callback = _ref3[_j];
            _results1.push(callback(endpoint.Name, connection.Address));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    }
  };

  return EndpointHandler;

})();

module.exports = EndpointHandler;

//# sourceMappingURL=endpointHandler.js.map