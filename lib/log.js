var Diag, Log, Variable, util,
  __slice = [].slice;

Diag = require("./diag");

util = require('util');

Variable = (function() {
  function Variable(content) {
    this.content = content;
  }

  Variable.prototype.toString = function() {
    return util.inspect(this.content, {
      depth: null
    });
  };

  return Variable;

})();

Log = (function() {
  function Log() {}

  Log.levels = {
    SILENT: 'silent',
    TRACE: 'trace',
    DEBUG: 'debug',
    INFO: 'info',
    WARN: 'warn',
    ERROR: 'error'
  };

  Log.level = 'trace';

  Log.setComponentName = function(name) {
    return Diag.componentName = name;
  };

  Log.trace = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if ((_ref = this.level) === 'trace') {
      return Diag.log('VIRTDB_SIMPLE_TRACE', args);
    }
  };

  Log.debug = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if ((_ref = this.level) === 'trace' || _ref === 'debug') {
      return Diag.log('VIRTDB_SIMPLE_TRACE', args);
    }
  };

  Log.info = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if ((_ref = this.level) === 'trace' || _ref === 'debug' || _ref === 'info') {
      return Diag.log('VIRTDB_INFO', args);
    }
  };

  Log.warn = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if ((_ref = this.level) === 'trace' || _ref === 'debug' || _ref === 'info' || _ref === 'warn') {
      return Diag.log('VIRTDB_INFO', args);
    }
  };

  Log.error = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if ((_ref = this.level) === 'trace' || _ref === 'debug' || _ref === 'info' || _ref === 'warn' || _ref === 'error') {
      return Diag.log('VIRTDB_ERROR', args);
    }
  };

  Log.setLevel = function(level) {
    return Log.level = typeof level.toLowerCase === "function" ? level.toLowerCase() : void 0;
  };

  Log.enableAll = function() {
    return Log.setLevel(Log.levels.TRACE);
  };

  Log.disableAll = function() {
    return Log.setLevel(Log.levels.SILENT);
  };

  Log.enableConsoleLog = function(isEnabled) {
    return Diag.isConsoleLogEnabled = isEnabled;
  };

  Log.Variable = function(param) {
    return new Variable(param);
  };

  return Log;

})();

module.exports = Log;

//# sourceMappingURL=log.js.map