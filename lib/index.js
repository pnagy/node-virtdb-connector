var Constants, Convert, EndpointHandler, Protocol, VirtDBConnector, log, udp, zmq;

udp = require('dgram');

Protocol = require('./protocol');

EndpointHandler = require('./endpointHandler');

log = require('./log');

zmq = require('zmq');

Constants = require('./constants');

Convert = require('./convert');

VirtDBConnector = (function() {
  function VirtDBConnector() {}

  VirtDBConnector.FieldData = require("./fieldData");

  VirtDBConnector.ALL_TYPE = EndpointHandler.ALL_TYPE;

  VirtDBConnector.IP = null;

  VirtDBConnector.log = log;

  VirtDBConnector.Constants = Constants;

  VirtDBConnector.Sockets = {};

  VirtDBConnector.Convert = Convert;

  VirtDBConnector.handler = new EndpointHandler();

  VirtDBConnector.callbacks = [];

  VirtDBConnector.PubSubCallbacks = null;

  VirtDBConnector.connect = function(name, connectionString) {
    var endpoint;
    VirtDBConnector.handler.on('IP_DISCOVERY', 'RAW_UDP', function(name, addresses) {
      return VirtDBConnector._findMyIP(addresses[0]);
    });
    VirtDBConnector.handler.on('LOG_RECORD', 'PUSH_PULL', function(name, addresses) {
      return Protocol.connectToDiag(addresses);
    });
    VirtDBConnector.subscribe('ENDPOINT', VirtDBConnector.handler.onPublishedEndpointMessage);
    VirtDBConnector.handler.connect(connectionString);
    log.setComponentName(name);
    endpoint = {
      Endpoints: [
        {
          Name: name,
          SvcType: 'NONE'
        }
      ]
    };
    return VirtDBConnector.handler.send(endpoint);
  };

  VirtDBConnector.close = function() {
    var endpoint_name, ref, service_type;
    if ((ref = VirtDBConnector.handler) != null) {
      ref.close();
    }
    VirtDBConnector.IP = null;
    for (endpoint_name in VirtDBConnector.Sockets) {
      for (service_type in VirtDBConnector.Sockets[endpoint_name]) {
        VirtDBConnector.Sockets[endpoint_name][service_type].close();
      }
    }
    VirtDBConnector.Sockets = {};
    VirtDBConnector.handler = new EndpointHandler();
    VirtDBConnector.callbacks = [];
    if (Protocol != null) {
      Protocol.close();
    }
    return VirtDBConnector.PubSubCallbacks = null;
  };

  VirtDBConnector.onAddress = function(service_type, connection_type, callback) {
    return VirtDBConnector.handler.on(service_type, connection_type, callback);
  };

  VirtDBConnector.subscribe = function(service_type, callback, channel) {
    var base;
    if (VirtDBConnector.PubSubCallbacks == null) {
      VirtDBConnector.PubSubCallbacks = {};
    }
    if ((base = VirtDBConnector.PubSubCallbacks)[service_type] == null) {
      base[service_type] = [];
    }
    VirtDBConnector.PubSubCallbacks[service_type].push(callback);
    return VirtDBConnector.handler.on(service_type, 'PUB_SUB', function(name, addresses) {
      var address, base1, i, len, ref, ref1, socket;
      socket = (ref = VirtDBConnector.Sockets) != null ? (ref1 = ref[name]) != null ? ref1[service_type] : void 0 : void 0;
      if (socket == null) {
        socket = zmq.socket('sub');
      }
      socket.on("message", function(channel, message) {
        var i, len, ref2, results;
        ref2 = VirtDBConnector.PubSubCallbacks[service_type];
        results = [];
        for (i = 0, len = ref2.length; i < len; i++) {
          callback = ref2[i];
          results.push(callback(channel, message));
        }
        return results;
      });
      for (i = 0, len = addresses.length; i < len; i++) {
        address = addresses[i];
        socket.connect(address);
      }
      if (channel == null) {
        channel = "";
      }
      socket.subscribe(channel);
      if ((base1 = VirtDBConnector.Sockets)[name] == null) {
        base1[name] = {};
      }
      return VirtDBConnector.Sockets[name][service_type] = socket;
    });
  };

  VirtDBConnector.setupEndpoint = function(name, protocol_call, callback) {
    var onBound;
    onBound = function(name, socket, svcType, zmqType) {
      return function() {
        var endpoint, zmqAddress;
        zmqAddress = socket.getsockopt(zmq.ZMQ_LAST_ENDPOINT);
        log.info("Listening (" + svcType + ") on", zmqAddress);
        endpoint = {
          Endpoints: [
            {
              Name: name,
              SvcType: svcType,
              Connections: [
                {
                  Type: zmqType,
                  Address: [zmqAddress]
                }
              ]
            }
          ]
        };
        return VirtDBConnector.handler.send(endpoint);
      };
    };
    if (VirtDBConnector.IP != null) {
      log.info("Our IP:", VirtDBConnector.IP);
      protocol_call(name, 'tcp://' + VirtDBConnector.IP + ':*', callback, onBound);
    } else {
      VirtDBConnector.callbacks.push(function() {
        return protocol_call(name, 'tcp://' + VirtDBConnector.IP + ':*', callback, onBound);
      });
    }
  };

  VirtDBConnector._findMyIP = function(discoveryAddress) {
    var address, client, ip, parts, port, wait_for_ip;
    if (discoveryAddress.indexOf('raw_udp://' === 0)) {
      client = null;
      address = discoveryAddress.replace(/^raw_udp:\/\//, '');
      if (address.indexOf('[') > -1) {
        ip = address.replace(/^\[|\]:[0-9]{2,5}/g, '');
        port = address.replace(/\[.*\]:/g, '');
        client = udp.createSocket('udp6');
      } else {
        parts = address.split(':');
        ip = parts[0];
        port = parts[1];
        client = udp.createSocket('udp4');
      }
      if (client != null) {
        client.on('message', function(message, remote) {
          var callback, i, len, ref;
          VirtDBConnector.IP = message.toString();
          ref = VirtDBConnector.callbacks;
          for (i = 0, len = ref.length; i < len; i++) {
            callback = ref[i];
            callback();
          }
          VirtDBConnector.callbacks = [];
          return client.close();
        });
      }
      wait_for_ip = function(client, port, ip) {
        var ex, message;
        if (VirtDBConnector.IP != null) {

        } else {
          try {
            message = new Buffer('?');
            if (client != null) {
              client.send(message, 0, 1, port, ip, function(err, bytes) {
                if (err) {
                  return log.error(err);
                }
              });
            }
          } catch (_error) {
            ex = _error;
            log.error(ex);
          }
          return setTimeout(wait_for_ip, 10, client, port, ip);
        }
      };
      return wait_for_ip(client, port, ip);
    }
  };

  return VirtDBConnector;

})();

module.exports = VirtDBConnector;

//# sourceMappingURL=index.js.map