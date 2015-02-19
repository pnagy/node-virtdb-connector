var BoolFieldData, BytesFieldData, DoubleFieldData, FieldData, FloatFieldData, Int32FieldData, Int64FieldData, StringFieldData, UInt32FieldData, UInt64FieldData,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

FieldData = (function() {
  FieldData.prototype.length = null;

  FieldData.createInstance = function(name, type) {
    switch (type) {
      case "STRING":
        return new StringFieldData(name, type);
      case "INT32":
        return new Int32FieldData(name, type);
      case "INT64":
        return new Int64FieldData(name, type);
      case "UINT32":
        return new UInt32FieldData(name, type);
      case "UINT64":
        return new UInt64FieldData(name, type);
      case "DOUBLE":
        return new DoubleFieldData(name, type);
      case "FLOAT":
        return new FloatFieldData(name, type);
      case "BOOL":
        return new BoolFieldData(name, type);
      case "BYTES":
        return new BytesFieldData(name, type);
      default:
        return new StringFieldData(name, type);
    }
  };

  FieldData.createInstanceFromField = function(field) {
    return this.createInstance(field.name, field.Desc.Type);
  };

  FieldData.get = function(data) {
    var local;
    local = FieldData.createInstance(data.Data.Name, data.Data.Type);
    local.pushArray(data.Data);
    return local.getArray();
  };

  function FieldData(FieldName, Type) {
    this.FieldName = FieldName;
    this.Type = Type;
    this.pushArray = bind(this.pushArray, this);
    this.push = bind(this.push, this);
    this.length = 0;
    this.IsNull = new Array();
  }

  FieldData.prototype.push = function(value) {
    return this.IsNull.push(value);
  };

  FieldData.prototype.pushArray = function(items) {
    var i, item, len, results;
    results = [];
    for (i = 0, len = items.length; i < len; i++) {
      item = items[i];
      results.push(this.push(item));
    }
    return results;
  };

  return FieldData;

})();

StringFieldData = (function(superClass) {
  extend(StringFieldData, superClass);

  function StringFieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    StringFieldData.__super__.constructor.call(this, fieldName, type);
    this.StringValue = new Array();
  }

  StringFieldData.prototype.push = function(value) {
    this.StringValue.push(value);
    this.length = this.StringValue.length;
    return StringFieldData.__super__.push.call(this, value === "");
  };

  StringFieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.StringValue = data.StringValue;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.StringValue[index] = null;
      }
    }
    return this.length = this.StringValue.length;
  };

  StringFieldData.prototype.getArray = function() {
    return this.StringValue;
  };

  StringFieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.StringValue[index];
    } else {
      return null;
    }
  };

  return StringFieldData;

})(FieldData);

Int32FieldData = (function(superClass) {
  extend(Int32FieldData, superClass);

  function Int32FieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    Int32FieldData.__super__.constructor.apply(this, arguments);
    this.Int32Value = new Array();
  }

  Int32FieldData.prototype.push = function(value) {
    var numberValue;
    if (value !== "") {
      numberValue = Number(value);
      if (!isNaN(numberValue) && numberValue > -2147483648 && numberValue < 2147483647) {
        this.Int32Value.push(Number(value));
        this.length = this.Int32Value.length;
        return Int32FieldData.__super__.push.call(this, false);
      }
    }
    this.Int32Value.push(null);
    this.length = this.Int32Value.length;
    return Int32FieldData.__super__.push.call(this, true);
  };

  Int32FieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.Int32Value = data.Int32Value;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.Int32Value[index] = null;
      }
    }
    return this.length = this.Int32Value.length;
  };

  Int32FieldData.prototype.getArray = function() {
    return this.Int32Value;
  };

  Int32FieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.Int32Value[index];
    } else {
      return null;
    }
  };

  return Int32FieldData;

})(FieldData);

Int64FieldData = (function(superClass) {
  extend(Int64FieldData, superClass);

  function Int64FieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    Int64FieldData.__super__.constructor.apply(this, arguments);
    this.Int64Value = new Array();
  }

  Int64FieldData.prototype.push = function(value) {
    var numberValue;
    if (value !== "") {
      numberValue = Number(value);
      if (!isNaN(numberValue) && numberValue > -9223372036854775808 && numberValue < 9223372036854775807) {
        this.Int64Value.push(Number(value));
        this.length = this.Int64Value.length;
        return Int64FieldData.__super__.push.call(this, false);
      }
    }
    this.length = this.Int64Value.length;
    this.Int64Value.push(null);
    return Int64FieldData.__super__.push.call(this, true);
  };

  Int64FieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.Int64Value = data.Int64Value;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.Int64Value[index] = null;
      }
    }
    return this.length = this.Int64Value.length;
  };

  Int64FieldData.prototype.getArray = function() {
    return this.Int64Value;
  };

  Int64FieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.Int64Value[index];
    } else {
      return null;
    }
  };

  return Int64FieldData;

})(FieldData);

UInt32FieldData = (function(superClass) {
  extend(UInt32FieldData, superClass);

  function UInt32FieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    UInt32FieldData.__super__.constructor.apply(this, arguments);
    this.UInt32Value = new Array();
  }

  UInt32FieldData.prototype.push = function(value) {
    var numberValue;
    if (value !== "") {
      numberValue = Number(value);
      if (!isNaN(numberValue) && numberValue >= 0 && numberValue < 4294967295) {
        this.UInt32Value.push(Number(value));
        this.length = this.UInt32Value.length;
        return UInt32FieldData.__super__.push.call(this, false);
      }
    }
    this.UInt32Value.push(null);
    this.length = this.UInt32Value.length;
    return UInt32FieldData.__super__.push.call(this, true);
  };

  UInt32FieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.UInt32Value = data.UInt32Value;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.UInt32Value[index] = null;
      }
    }
    return this.length = this.UInt32Value.length;
  };

  UInt32FieldData.prototype.getArray = function() {
    return this.UInt32Value;
  };

  UInt32FieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.UInt32Value[index];
    } else {
      return null;
    }
  };

  return UInt32FieldData;

})(FieldData);

UInt64FieldData = (function(superClass) {
  extend(UInt64FieldData, superClass);

  function UInt64FieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    UInt64FieldData.__super__.constructor.apply(this, arguments);
    this.UInt64Value = new Array();
  }

  UInt64FieldData.prototype.push = function(value) {
    var numberValue;
    if (value !== "") {
      numberValue = Number(value);
      if (!isNaN(numberValue) && numberValue >= 0) {
        this.UInt64Value.push(Number(value));
        this.length = this.UInt64Value.length;
        return UInt64FieldData.__super__.push.call(this, false);
      }
    }
    this.UInt64Value.push(null);
    this.length = this.UInt64Value.length;
    return UInt64FieldData.__super__.push.call(this, true);
  };

  UInt64FieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.UInt64Value = data.UInt64Value;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.UInt64Value[index] = null;
      }
    }
    return this.length = this.UInt64Value.length;
  };

  UInt64FieldData.prototype.getArray = function() {
    return this.UInt64Value;
  };

  UInt64FieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.UInt64Value[index];
    } else {
      return null;
    }
  };

  return UInt64FieldData;

})(FieldData);

DoubleFieldData = (function(superClass) {
  extend(DoubleFieldData, superClass);

  function DoubleFieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    DoubleFieldData.__super__.constructor.apply(this, arguments);
    this.DoubleValue = new Array();
  }

  DoubleFieldData.prototype.push = function(value) {
    var numberValue;
    if (value !== "" && value.toString().length < 15) {
      numberValue = parseFloat(value);
      if (!isNaN(numberValue)) {
        this.DoubleValue.push(Number(value));
        this.length = this.DoubleValue.length;
        return DoubleFieldData.__super__.push.call(this, false);
      }
    }
    this.DoubleValue.push(null);
    this.length = this.DoubleValue.length;
    return DoubleFieldData.__super__.push.call(this, true);
  };

  DoubleFieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.DoubleValue = data.DoubleValue;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.DoubleValue[index] = null;
      }
    }
    return this.length = this.DoubleValue.length;
  };

  DoubleFieldData.prototype.getArray = function() {
    return this.DoubleValue;
  };

  DoubleFieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.DoubleValue[index];
    } else {
      return null;
    }
  };

  return DoubleFieldData;

})(FieldData);

FloatFieldData = (function(superClass) {
  extend(FloatFieldData, superClass);

  function FloatFieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    FloatFieldData.__super__.constructor.apply(this, arguments);
    this.FloatValue = new Array();
  }

  FloatFieldData.prototype.push = function(value) {
    var numberValue;
    if (value !== "" && value.toString().length < 7) {
      numberValue = parseFloat(value);
      if (!isNaN(numberValue)) {
        this.FloatValue.push(Number(value));
        this.length = this.FloatValue.length;
        return FloatFieldData.__super__.push.call(this, false);
      }
    }
    this.FloatValue.push(null);
    this.length = this.FloatValue.length;
    return FloatFieldData.__super__.push.call(this, true);
  };

  FloatFieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.FloatValue = data.FloatValue;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.FloatValue[index] = null;
      }
    }
    return this.length = this.FloatValue.length;
  };

  FloatFieldData.prototype.getArray = function() {
    return this.FloatValue;
  };

  FloatFieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.FloatValue[index];
    } else {
      return null;
    }
  };

  return FloatFieldData;

})(FieldData);

BoolFieldData = (function(superClass) {
  extend(BoolFieldData, superClass);

  function BoolFieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    BoolFieldData.__super__.constructor.apply(this, arguments);
    this.BoolValue = new Array();
  }

  BoolFieldData.prototype.push = function(value) {
    if (value.toString() === 'true' || value.toString() === 'false') {
      this.BoolValue.push(value);
      this.length = this.BoolValue.length;
      return BoolFieldData.__super__.push.call(this, false);
    }
    this.BoolValue.push(null);
    this.length = this.BoolValue.length;
    return BoolFieldData.__super__.push.call(this, true);
  };

  BoolFieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.BoolValue = data.BoolValue;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.BoolValue[index] = null;
      }
    }
    return this.length = this.BoolValue.length;
  };

  BoolFieldData.prototype.getArray = function() {
    return this.BoolValue;
  };

  BoolFieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.BoolValue[index];
    } else {
      return null;
    }
  };

  return BoolFieldData;

})(FieldData);

BytesFieldData = (function(superClass) {
  extend(BytesFieldData, superClass);

  function BytesFieldData(fieldName, type) {
    this.get = bind(this.get, this);
    this.getArray = bind(this.getArray, this);
    this.pushValueType = bind(this.pushValueType, this);
    this.push = bind(this.push, this);
    BytesFieldData.__super__.constructor.apply(this, arguments);
    this.BytesValue = new Array();
  }

  BytesFieldData.prototype.push = function(value) {
    var i, len, v, vNumber;
    for (i = 0, len = value.length; i < len; i++) {
      v = value[i];
      vNumber = Number(v);
      if (isNaN(vNumber) || vNumber < 0 || vNumber > 255) {
        value = null;
        break;
      }
    }
    this.BytesValue.push(value);
    this.length = this.BytesValue.length;
    return BytesFieldData.__super__.push.call(this, false);
  };

  BytesFieldData.prototype.pushValueType = function(data) {
    var i, index, item, len, ref;
    this.BytesValue = data.BytesValue;
    ref = data.IsNull;
    for (index = i = 0, len = ref.length; i < len; index = ++i) {
      item = ref[index];
      if (item) {
        this.BytesValue[index] = null;
      }
    }
    return this.length = this.BytesValue.length;
  };

  BytesFieldData.prototype.getArray = function() {
    return this.BytesValue;
  };

  BytesFieldData.prototype.get = function(index) {
    if (!this.IsNull[index]) {
      return this.BytesValue[index];
    } else {
      return null;
    }
  };

  return BytesFieldData;

})(FieldData);

module.exports = FieldData;

//# sourceMappingURL=fieldData.js.map