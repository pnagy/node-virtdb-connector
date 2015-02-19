var Diag, Log, Variable, util,
  slice = [].slice;

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

  Log.Levels = {
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
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if ((ref = this.level) === 'trace') {
      return Diag.log('VIRTDB_SIMPLE_TRACE', args);
    }
  };

  Log.debug = function() {
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if ((ref = this.level) === 'trace' || ref === 'debug') {
      return Diag.log('VIRTDB_SIMPLE_TRACE', args);
    }
  };

  Log.info = function() {
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if ((ref = this.level) === 'trace' || ref === 'debug' || ref === 'info') {
      return Diag.log('VIRTDB_INFO', args);
    }
  };

  Log.warn = function() {
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if ((ref = this.level) === 'trace' || ref === 'debug' || ref === 'info' || ref === 'warn') {
      return Diag.log('VIRTDB_INFO', args);
    }
  };

  Log.error = function() {
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if ((ref = this.level) === 'trace' || ref === 'debug' || ref === 'info' || ref === 'warn' || ref === 'error') {
      return Diag.log('VIRTDB_ERROR', args);
    }
  };

  Log.setLevel = function(level) {
    return Log.level = typeof level.toLowerCase === "function" ? level.toLowerCase() : void 0;
  };

  Log.enableAll = function() {
    return Log.setLevel(Log.Levels.TRACE);
  };

  Log.disableAll = function() {
    return Log.setLevel(Log.Levels.SILENT);
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