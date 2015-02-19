var EndpointHandler, log, proto_service_config, protobuf, zmq,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
    this._getMatchingHandlers = bind(this._getMatchingHandlers, this);
    this.onEndpoint = bind(this.onEndpoint, this);
    this.handleEndpointMessage = bind(this.handleEndpointMessage, this);
    this.onPublishedEndpointMessage = bind(this.onPublishedEndpointMessage, this);
    this.on = bind(this.on, this);
    this.close = bind(this.close, this);
    this.send = bind(this.send, this);
    this.Handlers = {};
  }

  EndpointHandler.prototype.connect = function(connectionString) {
    this.svcConfigSocket = zmq.socket('req');
    this.svcConfigSocket.on('message', this.handleEndpointMessage);
    return this.svcConfigSocket.connect(connectionString);
  };

  EndpointHandler.prototype.send = function(endpoint) {
    return this.svcConfigSocket.send(proto_service_config.serialize(endpoint, 'virtdb.interface.pb.Endpoint'));
  };

  EndpointHandler.prototype.close = function() {
    var ref;
    if ((ref = this.svcConfigSocket) != null) {
      ref.close();
    }
    return this.Handlers = {};
  };

  EndpointHandler.prototype.on = function(service_type, connection_type, callback) {
    var base, base1;
    if ((base = this.Handlers)[service_type] == null) {
      base[service_type] = {};
    }
    if ((base1 = this.Handlers[service_type])[connection_type] == null) {
      base1[connection_type] = [];
    }
    return this.Handlers[service_type][connection_type].push(callback);
  };

  EndpointHandler.prototype.onPublishedEndpointMessage = function(channel, message) {
    return this.handleEndpointMessage(message);
  };

  EndpointHandler.prototype.handleEndpointMessage = function(message) {
    var endpoint, endpointMessage, i, len, ref, results;
    endpointMessage = proto_service_config.parse(message, 'virtdb.interface.pb.Endpoint');
    ref = endpointMessage.Endpoints;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      endpoint = ref[i];
      results.push(this.onEndpoint(endpoint));
    }
    return results;
  };

  EndpointHandler.prototype.onEndpoint = function(endpoint) {
    var connection, handler, i, len, ref, results;
    if (endpoint.Connections != null) {
      ref = endpoint.Connections;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        connection = ref[i];
        results.push((function() {
          var j, len1, ref1, results1;
          ref1 = this._getMatchingHandlers(endpoint.SvcType, connection.Type);
          results1 = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            handler = ref1[j];
            results1.push(handler(endpoint.Name, connection.Address, endpoint.SvcType, connection.Type));
          }
          return results1;
        }).call(this));
      }
      return results;
    }
  };

  EndpointHandler.prototype._getMatchingHandlers = function(svcType, connectionType) {
    var handler, handlers, i, j, k, l, len, len1, len2, len3, ref, ref1, ref10, ref11, ref12, ref13, ref14, ref15, ref16, ref17, ref18, ref19, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
    handlers = [];
    if (((ref = this.Handlers) != null ? (ref1 = ref[EndpointHandler.ALL_TYPE]) != null ? ref1[EndpointHandler.ALL_TYPE] : void 0 : void 0) != null) {
      ref4 = (ref2 = this.Handlers) != null ? (ref3 = ref2[EndpointHandler.ALL_TYPE]) != null ? ref3[EndpointHandler.ALL_TYPE] : void 0 : void 0;
      for (i = 0, len = ref4.length; i < len; i++) {
        handler = ref4[i];
        handlers.push(handler);
      }
    }
    if (((ref5 = this.Handlers) != null ? (ref6 = ref5[svcType]) != null ? ref6[EndpointHandler.ALL_TYPE] : void 0 : void 0) != null) {
      ref9 = (ref7 = this.Handlers) != null ? (ref8 = ref7[svcType]) != null ? ref8[EndpointHandler.ALL_TYPE] : void 0 : void 0;
      for (j = 0, len1 = ref9.length; j < len1; j++) {
        handler = ref9[j];
        handlers.push(handler);
      }
    }
    if (((ref10 = this.Handlers) != null ? (ref11 = ref10[EndpointHandler.ALL_TYPE]) != null ? ref11[connectionType] : void 0 : void 0) != null) {
      ref14 = (ref12 = this.Handlers) != null ? (ref13 = ref12[EndpointHandler.ALL_TYPE]) != null ? ref13[connectionType] : void 0 : void 0;
      for (k = 0, len2 = ref14.length; k < len2; k++) {
        handler = ref14[k];
        handlers.push(handler);
      }
    }
    if (((ref15 = this.Handlers) != null ? (ref16 = ref15[svcType]) != null ? ref16[connectionType] : void 0 : void 0) != null) {
      ref19 = (ref17 = this.Handlers) != null ? (ref18 = ref17[svcType]) != null ? ref18[connectionType] : void 0 : void 0;
      for (l = 0, len3 = ref19.length; l < len3; l++) {
        handler = ref19[l];
        handlers.push(handler);
      }
    }
    return handlers;
  };

  return EndpointHandler;

})();

module.exports = EndpointHandler;

//# sourceMappingURL=endpointHandler.js.map