var Diag, Protocol, os;

Protocol = require('./protocol');

os = require('os');

Date.prototype.yyyymmdd = function() {
  var dd, mm, yyyy;
  yyyy = this.getFullYear().toString();
  mm = (this.getMonth() + 1).toString();
  dd = this.getDate().toString();
  return yyyy + (mm[1] ? mm : "0" + mm[0]) + (dd[1] ? dd : "0" + dd[0]);
};

Date.prototype.hhmmss = function() {
  var hh, mm, ss;
  hh = ('0' + this.getHours().toString()).slice(-2);
  mm = ('0' + this.getMinutes().toString()).slice(-2);
  ss = ('0' + this.getSeconds().toString()).slice(-2);
  return hh + mm + ss;
};

Object.defineProperty(global, "__stack", {
  get: function() {
    var err, orig, stack;
    orig = Error.prepareStackTrace;
    Error.prepareStackTrace = function(_, stack) {
      return stack;
    };
    err = new Error;
    Error.captureStackTrace(err, arguments.callee);
    stack = err.stack;
    Error.prepareStackTrace = orig;
    return stack;
  }
});

Object.defineProperty(global, "__line", {
  get: function() {
    return __stack[4].getLineNumber();
  }
});

Object.defineProperty(global, "__file", {
  get: function() {
    var name;
    name = __stack[4].getFileName();
    return name.substring(process.cwd().length, name.length);
  }
});

Object.defineProperty(global, "__func", {
  get: function() {
    return __stack[4].getFunctionName() || "";
  }
});

Diag = (function() {
  function Diag() {}

  Diag._startHR = null;

  Diag._startDate = null;

  Diag._startTime = null;

  Diag._random = null;

  Diag._name = null;

  Diag._symbols = {};

  Diag._newSymbols = [];

  Diag._headers = {};

  Diag._newHeaders = [];

  Diag.isConsoleLogEnabled = false;

  Diag.componentName = null;

  Diag.startDate = function() {
    if (Diag._startDate == null) {
      Diag._startDate = new Date().yyyymmdd();
    }
    return Diag._startDate;
  };

  Diag.startTime = function() {
    if (Diag._startTime == null) {
      Diag._startTime = new Date().hhmmss();
    }
    return Diag._startTime;
  };

  Diag.random = function() {
    if (Diag._random == null) {
      Diag._random = Math.floor(Math.random() * 100000000 + 1);
    }
    return Diag._random;
  };

  Diag._getProcessInfo = function() {
    var Process;
    Process = {
      StartDate: Diag.startDate(),
      StartTime: Diag.startTime(),
      Pid: process.pid,
      Random: Diag.random(),
      NameSymbol: Diag._getSymbolSeqNo(Diag.componentName),
      HostSymbol: Diag._getSymbolSeqNo(os.hostname())
    };
    return Process;
  };

  Diag._getNewSymbols = function() {
    var Symbols, symbol, _i, _len, _ref;
    Symbols = [];
    _ref = Diag._newSymbols;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      symbol = _ref[_i];
      Symbols.push(symbol);
    }
    Diag._newSymbols = [];
    return Symbols;
  };

  Diag._getNewHeaders = function() {
    var Headers, header, _i, _len, _ref;
    Headers = [];
    _ref = Diag._newHeaders;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      header = _ref[_i];
      Headers.push(header);
    }
    Diag._newHeaders = [];
    return Headers;
  };

  Diag._getSymbolSeqNo = function(symbolValue) {
    if (!(symbolValue in Diag._symbols)) {
      Diag._symbols[symbolValue] = Object.keys(Diag._symbols).length;
      Diag._newSymbols.push({
        SeqNo: Diag._symbols[symbolValue],
        Value: symbolValue
      });
    }
    return Diag._symbols[symbolValue];
  };

  Diag._getHeaderSeqNo = function(file, func, line, level, args) {
    var argument, key, _i, _len;
    key = '' + file + func + line + level + args.length;
    if (!(key in Diag._headers)) {
      Diag._headers[key] = {
        SeqNo: Object.keys(Diag._headers).length,
        FileNameSymbol: Diag._getSymbolSeqNo(file),
        LineNumber: line,
        FunctionNameSymbol: Diag._getSymbolSeqNo(func),
        Level: level,
        LogStringSymbol: 0,
        Parts: []
      };
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        argument = args[_i];
        switch (typeof argument) {
          case 'object':
            Diag._headers[key].Parts.push({
              IsVariable: true,
              HasData: true,
              Type: 'STRING'
            });
            break;
          default:
            Diag._headers[key].Parts.push({
              IsVariable: false,
              HasData: false,
              Type: 'STRING',
              PartSymbol: Diag._getSymbolSeqNo(argument)
            });
        }
      }
      Diag._newHeaders.push(Diag._headers[key]);
    }
    return Diag._headers[key].SeqNo;
  };

  Diag._value = function(argument) {
    var ret;
    switch (typeof argument) {
      case 'string':
        return ret = {
          Type: 'STRING',
          StringValue: [argument],
          IsNull: [false]
        };
      case 'number':
        if (!isFinite(argument)) {
          return ret = {
            Type: 'STRING',
            StringValue: [argument],
            IsNull: [false]
          };
        } else if (argument % 1 === 0) {
          return ret = {
            Type: 'INT64',
            Int64Value: [argument],
            IsNull: [false]
          };
        } else {
          return ret = {
            Type: 'DOUBLE',
            DoubleValue: [argument],
            IsNull: [false]
          };
        }
        break;
      default:
        return ret = {
          Type: 'STRING',
          StringValue: [argument != null ? argument.toString() : void 0],
          IsNull: [argument == null]
        };
    }
  };

  Diag._ellapsedMicrosec = function() {
    var ellapsed;
    if (Diag._startHR == null) {
      Diag._startHR = process.hrtime();
    }
    ellapsed = process.hrtime(Diag._startHR);
    return (ellapsed[0] * 1e9 + ellapsed[1]) / 1000;
  };

  Diag._createConsoleLogMessage = function(args) {
    var argTexts, message;
    message = "";
    argTexts = args.map(function(val) {
      return val.toString();
    });
    return argTexts.join(" ");
  };

  Diag._createDiagServiceMessage = function(level, args) {
    var argument, record, type, _i, _len;
    record = {};
    record.Process = Diag._getProcessInfo();
    record.Data = [
      {
        HeaderSeqNo: Diag._getHeaderSeqNo(__file, __func, __line, level, args),
        ElapsedMicroSec: Diag._ellapsedMicrosec(),
        ThreadId: 0,
        Values: []
      }
    ];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      argument = args[_i];
      type = typeof argument;
      switch (type) {
        case 'object':
          record.Data[0].Values.push(Diag._value(argument));
      }
    }
    record.Symbols = Diag._getNewSymbols();
    record.Headers = Diag._getNewHeaders();
    return record;
  };

  Diag.log = function(level, args) {
    var record;
    record = Diag._createDiagServiceMessage(level, args);
    if ((!Protocol.sendDiag(record)) || (Diag.isConsoleLogEnabled === true)) {
      return console.log(level + ": " + Diag._createConsoleLogMessage(args));
    }
  };

  return Diag;

})();

module.exports = Diag;

//# sourceMappingURL=diag.js.map