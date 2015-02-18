var EndpointHandler, log, proto_service_config, protobuf, zmq,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

zmq = require('zmq');

protobuf = require('virtdb-proto');

proto_service_config = protobuf.service_config;

log = require('./log');

EndpointHandler = (function() {
  var Handlers, svcConfigSocket;

  EndpointHandler.ALL_TYPE = "*";

  svcConfigSocket = null;

  Handlers = null;

  function EndpointHandler() {
    this._getMatchingHandlers = __bind(this._getMatchingHandlers, this);
    this.onEndpoint = __bind(this.onEndpoint, this);
    this.onEndpointMessage = __bind(this.onEndpointMessage, this);
    this.on = __bind(this.on, this);
    this.close = __bind(this.close, this);
    this.send = __bind(this.send, this);
    this.Handlers = {};
  }

  EndpointHandler.prototype.connect = function(connectionString) {
    this.svcConfigSocket = zmq.socket('req');
    this.svcConfigSocket.on('message', this.onEndpointMessage);
    return this.svcConfigSocket.connect(connectionString);
  };

  EndpointHandler.prototype.send = function(endpoint) {
    return this.svcConfigSocket.send(proto_service_config.serialize(endpoint, 'virtdb.interface.pb.Endpoint'));
  };

  EndpointHandler.prototype.close = function() {
    var _ref;
    if ((_ref = this.svcConfigSocket) != null) {
      _ref.close();
    }
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

  EndpointHandler.prototype.onEndpointMessage = function(message) {
    var endpoint, endpointMessage, _i, _len, _ref, _results;
    endpointMessage = proto_service_config.parse(message, 'virtdb.interface.pb.Endpoint');
    _ref = endpointMessage.Endpoints;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      endpoint = _ref[_i];
      _results.push(this.onEndpoint(endpoint));
    }
    return _results;
  };

  EndpointHandler.prototype.onEndpoint = function(endpoint) {
    var connection, handler, _i, _len, _ref, _results;
    if (endpoint.Connections != null) {
      _ref = endpoint.Connections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        connection = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = this._getMatchingHandlers(endpoint.SvcType, connection.Type);
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            handler = _ref1[_j];
            _results1.push(handler(endpoint.Name, connection.Address, endpoint.SvcType, connection.Type));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    }
  };

  EndpointHandler.prototype._getMatchingHandlers = function(svcType, connectionType) {
    var handler, handlers, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    handlers = [];
    if (((_ref = this.Handlers) != null ? (_ref1 = _ref[EndpointHandler.ALL_TYPE]) != null ? _ref1[EndpointHandler.ALL_TYPE] : void 0 : void 0) != null) {
      _ref4 = (_ref2 = this.Handlers) != null ? (_ref3 = _ref2[EndpointHandler.ALL_TYPE]) != null ? _ref3[EndpointHandler.ALL_TYPE] : void 0 : void 0;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        handler = _ref4[_i];
        handlers.push(handler);
      }
    }
    if (((_ref5 = this.Handlers) != null ? (_ref6 = _ref5[svcType]) != null ? _ref6[EndpointHandler.ALL_TYPE] : void 0 : void 0) != null) {
      _ref9 = (_ref7 = this.Handlers) != null ? (_ref8 = _ref7[svcType]) != null ? _ref8[EndpointHandler.ALL_TYPE] : void 0 : void 0;
      for (_j = 0, _len1 = _ref9.length; _j < _len1; _j++) {
        handler = _ref9[_j];
        handlers.push(handler);
      }
    }
    if (((_ref10 = this.Handlers) != null ? (_ref11 = _ref10[EndpointHandler.ALL_TYPE]) != null ? _ref11[connectionType] : void 0 : void 0) != null) {
      _ref14 = (_ref12 = this.Handlers) != null ? (_ref13 = _ref12[EndpointHandler.ALL_TYPE]) != null ? _ref13[connectionType] : void 0 : void 0;
      for (_k = 0, _len2 = _ref14.length; _k < _len2; _k++) {
        handler = _ref14[_k];
        handlers.push(handler);
      }
    }
    if (((_ref15 = this.Handlers) != null ? (_ref16 = _ref15[svcType]) != null ? _ref16[connectionType] : void 0 : void 0) != null) {
      _ref19 = (_ref17 = this.Handlers) != null ? (_ref18 = _ref17[svcType]) != null ? _ref18[connectionType] : void 0 : void 0;
      for (_l = 0, _len3 = _ref19.length; _l < _len3; _l++) {
        handler = _ref19[_l];
        handlers.push(handler);
      }
    }
    return handlers;
  };

  return EndpointHandler;

})();

module.exports = EndpointHandler;

//# sourceMappingURL=endpointHandler.js.map