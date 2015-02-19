var Convert;

Convert = (function() {
  var addDefault, addNodeToNew, addNodeToOld, addProperty, addRequired, addScope, addValue, getDefault, getRequired, getScope, getType, getValue, setValueArray;

  function Convert() {}

  setValueArray = function(type, defaultValue) {
    var value;
    value = {};
    value.Type = type;
    switch (type) {
      case "INT32":
        value.Int32Value = [];
        if (defaultValue != null) {
          value.Int32Value = [defaultValue];
        }
        break;
      case "INT64":
        value.Int64Value = [];
        if (defaultValue != null) {
          value.Int64Value = [defaultValue];
        }
        break;
      case "UINT32":
        value.UInt32Value = [];
        if (defaultValue != null) {
          value.UInt32Value = [defaultValue];
        }
        break;
      case "UINT64":
        value.UInt64Value = [];
        if (defaultValue != null) {
          value.UInt64Value = [defaultValue];
        }
        break;
      case "FLOAT":
        value.FloatValue = [];
        if (defaultValue != null) {
          value.FloatValue = [defaultValue];
        }
        break;
      case "DOUBLE":
        value.DoubleValue = [];
        if (defaultValue != null) {
          value.DoubleValue = [defaultValue];
        }
        break;
      case "BOOL":
        value.BoolValue = [];
        if (defaultValue != null) {
          value.BoolValue = [defaultValue];
        }
        break;
      case "BYTES":
        value.BytesValue = [];
        if (defaultValue != null) {
          value.BytesValue = [defaultValue];
        }
        break;
      default:
        value.StringValue = [];
        if (defaultValue != null) {
          value.StringValue = [defaultValue];
        }
    }
    return value;
  };

  addValue = function(object, config) {
    var index;
    if (config.Type != null) {
      index = object.Children.push({}) - 1;
      object.Children[index].Key = 'Value';
      return object.Children[index].Value = setValueArray(config.Type);
    }
  };

  addRequired = function(object, config) {
    var index;
    if (config.Required != null) {
      index = object.Children.push({}) - 1;
      object.Children[index].Key = 'Required';
      object.Children[index].Value = {};
      object.Children[index].Value.Type = 'BOOL';
      return object.Children[index].Value.BoolValue = [config.Required];
    }
  };

  addDefault = function(object, config) {
    var index;
    if ((config.Default != null) && (config.Type != null)) {
      index = object.Children.push({}) - 1;
      object.Children[index].Key = 'Default';
      object.Children[index].Value = {};
      object.Children[index].Value.Type = config.Type;
      return object.Children[index].Value = setValueArray(config.Type, config.Default);
    }
  };

  addScope = function(object, config, rootScope) {
    var index;
    if (config.Type != null) {
      if (config.Scope == null) {
        config.Scope = rootScope;
      }
      index = object.Children.push({}) - 1;
      object.Children[index].Key = 'Scope';
      object.Children[index].Value = {};
      object.Children[index].Value.Type = 'STRING';
      return object.Children[index].Value.StringValue = [config.Scope];
    }
  };

  addNodeToOld = function(destination, source, rootScope) {
    var config, i, len, object, results;
    results = [];
    for (i = 0, len = source.length; i < len; i++) {
      config = source[i];
      object = {};
      object.Key = config.VariableName;
      object.Children = [];
      addValue(object, config);
      addScope(object, config, rootScope);
      addRequired(object, config);
      addDefault(object, config);
      if (config.Children != null) {
        object.Children = [];
        addNodeToOld(object.Children, config.Children, config.Scope);
      }
      results.push(destination.push(object));
    }
    return results;
  };

  Convert.TemplateToOld = function(source) {
    var ret, root;
    ret = {};
    ret.Name = source.AppName;
    if (source.Config != null) {
      ret.ConfigData = [];
      ret.ConfigData.push({
        Key: "",
        Children: []
      });
      root = ret.ConfigData[0].Children;
      addNodeToOld(root, source.Config);
    }
    return ret;
  };

  getValue = function(value) {
    if (value == null) {
      return null;
    }
    switch (value.Type) {
      case "INT32":
        return value.Int32Value[0];
      case "INT64":
        return value.Int64Value[0];
      case "UINT32":
        return value.UInt32Value[0];
      case "UINT64":
        return value.UInt64Value[0];
      case "FLOAT":
        return value.FloatValue[0];
      case "DOUBLE":
        return value.DoubleValue[0];
      case "BOOL":
        return value.BoolValue[0];
      case "BYTES":
        return value.BytesValue[0];
      default:
        return value.StringValue[0];
    }
  };

  getScope = function(nodes) {
    var i, len, node;
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      if (node.Key === 'Scope') {
        return getValue(node.Value);
      }
    }
    return null;
  };

  getType = function(nodes) {
    var i, len, node;
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      if (node.Key === 'Value') {
        return node.Value.Type;
      }
    }
    return null;
  };

  getRequired = function(nodes) {
    var i, len, node;
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      if (node.Key === 'Required') {
        return node.Value.BoolValue[0];
      }
    }
    return null;
  };

  getDefault = function(nodes) {
    var i, len, node;
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      if (node.Key === 'Default') {
        return getValue(node.Value);
      }
    }
    return null;
  };

  addNodeToNew = function(destination, source) {
    var childrenScope, commonScope, defaultValue, i, isCommonScope, len, node, object, ref, required, scope, type;
    if (source == null) {
      return null;
    }
    isCommonScope = true;
    commonScope = null;
    for (i = 0, len = source.length; i < len; i++) {
      node = source[i];
      object = {};
      object.VariableName = node.Key;
      type = getType(node.Children);
      if (type != null) {
        object.Type = type;
      }
      required = getRequired(node.Children);
      if (required != null) {
        object.Required = required;
      }
      defaultValue = getDefault(node.Children);
      if (defaultValue != null) {
        object.Default = defaultValue;
      }
      if (((ref = node.Children[0]) != null ? ref.Children : void 0) != null) {
        object.Children = [];
        childrenScope = addNodeToNew(object.Children, node.Children);
        if (childrenScope != null) {
          object.Scope = childrenScope;
          if (commonScope == null) {
            commonScope = childrenScope;
          }
          if (commonScope !== childrenScope) {
            isCommonScope = false;
          }
        }
      }
      scope = getScope(node.Children);
      if (scope != null) {
        object.Scope = scope;
        if (commonScope == null) {
          commonScope = scope;
        }
        if (commonScope !== scope) {
          isCommonScope = false;
        }
      }
      destination.push(object);
    }
    if (isCommonScope) {
      return commonScope;
    } else {
      return null;
    }
  };

  Convert.TemplateToNew = function(source) {
    var ret;
    ret = {};
    ret.AppName = source.Name;
    ret.Config = [];
    addNodeToNew(ret.Config, source.ConfigData[0].Children);
    return ret;
  };

  Convert.ToNew = function(source) {
    var child, data, i, item, j, len, len1, ref, ref1, ret;
    ret = {};
    ret.AppName = source.Name;
    ret.Data = [];
    ref = source.ConfigData;
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      ref1 = item.Children;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        child = ref1[j];
        data = {};
        data.Location = [];
        data.Location.push(item.Key);
        data.Location.push(child.Key);
        data.Data = {};
        data.Data = child.Value;
        ret.Data.push(data);
      }
    }
    return ret;
  };

  addProperty = function(to, list, index, value) {
    var name;
    if (to[name = list[index]] == null) {
      to[name] = {};
    }
    if (list.length - 1 === index) {
      to[list[index]] = getValue(value);
      return;
    }
    return addProperty(to[list[index]], list, index + 1, value);
  };

  Convert.ToObject = function(source) {
    var i, item, len, ref, ret;
    ret = {};
    ref = source.Data;
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      addProperty(ret, item.Location, 0, item.Data);
    }
    return ret;
  };

  return Convert;

})();

module.exports = Convert;

//# sourceMappingURL=convert.js.map