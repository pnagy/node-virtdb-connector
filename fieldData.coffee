class FieldData
    length: null

    @createInstance: (name, type) ->
        switch type
            when "STRING"
                new StringFieldData(name, type)
            when "INT32"
                new Int32FieldData(name, type)
            when "INT64"
                new Int64FieldData(name, type)
            when "UINT32"
                new UInt32FieldData(name, type)
            when "UINT64"
                new UInt64FieldData(name, type)
            when "DOUBLE"
                new DoubleFieldData(name, type)
            when "FLOAT"
                new FloatFieldData(name, type)
            when "BOOL"
                new BoolFieldData(name, type)
            when "BYTES"
                new BytesFieldData(name, type)
            else # "DATE", "TIME", "DATETIME", "NUMERIC", "INET4", "INET6", "MAC", "GEODATA"
                new StringFieldData(name, type)

    @createInstanceFromField: (field) ->
        @createInstance field.name, field.Desc.Type

    @get: (data) =>
        local = @createInstance data.Data.Name, data.Data.Type
        local.pushValueType data.Data
        return local.getArray()

    constructor: (@FieldName, @Type) ->
        @length = 0
        @IsNull = new Array()

    # Call from not supported descendant classes only
    push: (value) =>
        @IsNull.push value

    pushArray: (items) =>
        for item in items
            @push item


class StringFieldData extends FieldData
    constructor: (fieldName, type) ->
        super fieldName, type
        @StringValue = new Array()

    push: (value) =>
        @StringValue.push value
        @length = @StringValue.length
        super(value == "")

    pushValueType: (data) =>
        @StringValue = data.StringValue
        for item, index in data.IsNull
            @StringValue[index] = null if item
        @length = @StringValue.length

    getArray: () =>
        @StringValue

    get: (index) =>
        if not @IsNull[index]
            @StringValue[index]
        else
            null


class Int32FieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @Int32Value = new Array()

    push: (value) =>
        if value != ""
            numberValue = Number(value)
            if (not isNaN(numberValue) and numberValue > -2147483648 and numberValue < 2147483647)
                @Int32Value.push Number(value)
                @length = @Int32Value.length
                return super(false)
        @Int32Value.push null
        @length = @Int32Value.length
        super(true)

    pushValueType: (data) =>
        @Int32Value = data.Int32Value
        for item, index in data.IsNull
            @Int32Value[index] = null if item
        @length = @Int32Value.length

    getArray: () =>
        @Int32Value

    get: (index) =>
        if not @IsNull[index]
            @Int32Value[index]
        else
            null

class Int64FieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @Int64Value = new Array()

    push: (value) =>
        if value != ""
            numberValue = Number(value)
            if (not isNaN(numberValue) and numberValue > -9223372036854775808 and numberValue < 9223372036854775807)
                @Int64Value.push Number(value)
                @length = @Int64Value.length
                return super(false)
        @length = @Int64Value.length
        @Int64Value.push null
        super(true)

    pushValueType: (data) =>
        @Int64Value = data.Int64Value
        for item, index in data.IsNull
            @Int64Value[index] = null if item
        @length = @Int64Value.length

    getArray: () =>
        @Int64Value

    get: (index) =>
        if not @IsNull[index]
            @Int64Value[index]
        else
            null


class UInt32FieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @UInt32Value = new Array()

    push: (value) =>
        if value != ""
            numberValue = Number(value)
            if (not isNaN(numberValue) and numberValue >= 0 and numberValue < 4294967295)
                @UInt32Value.push Number(value)
                @length = @UInt32Value.length
                return super(false)
        @UInt32Value.push null
        @length = @UInt32Value.length
        super(true)

    pushValueType: (data) =>
        @UInt32Value = data.UInt32Value
        for item, index in data.IsNull
            @UInt32Value[index] = null if item
        @length = @UInt32Value.length

    getArray: () =>
        @UInt32Value

    get: (index) =>
        if !@IsNull[index]
            @UInt32Value[index]
        else
            null


class UInt64FieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @UInt64Value = new Array()

    push: (value) =>
        if value != ""
            numberValue = Number(value)
            if (not isNaN(numberValue) and numberValue >= 0)
                @UInt64Value.push Number(value)
                @length = @UInt64Value.length
                return super(false)
        @UInt64Value.push null
        @length = @UInt64Value.length
        super(true)

    pushValueType: (data) =>
        @UInt64Value = data.UInt64Value
        for item, index in data.IsNull
            @UInt64Value[index] = null if item
        @length = @UInt64Value.length

    getArray: () =>
        @UInt64Value

    get: (index) =>
        if !@IsNull[index]
            @UInt64Value[index]
        else
            null


class DoubleFieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @DoubleValue = new Array()

    push: (value) =>
        if value != "" and value.toString().length < 15
            numberValue = parseFloat(value)
            if (not isNaN(numberValue))
                @DoubleValue.push Number(value)
                @length = @DoubleValue.length
                return super(false)
        @DoubleValue.push null
        @length = @DoubleValue.length
        super(true)

    pushValueType: (data) =>
        @DoubleValue = data.DoubleValue
        for item, index in data.IsNull
            @DoubleValue[index] = null if item
        @length = @DoubleValue.length

    getArray: () =>
        @DoubleValue

    get: (index) =>
        if !@IsNull[index]
            @DoubleValue[index]
        else
            null


class FloatFieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @FloatValue = new Array()

    push: (value) =>
        if value != "" and value.toString().length < 7
            numberValue = parseFloat(value)
            if (not isNaN(numberValue))
                @FloatValue.push Number(value)
                @length = @FloatValue.length
                return super(false)
        @FloatValue.push null
        @length = @FloatValue.length
        super(true)

    pushValueType: (data) =>
        @FloatValue = data.FloatValue
        for item, index in data.IsNull
            @FloatValue[index] = null if item
        @length = @FloatValue.length

    getArray: () =>
        @FloatValue

    get: (index) =>
        if !@IsNull[index]
            @FloatValue[index]
        else
            null


class BoolFieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @BoolValue = new Array()

    push: (value) =>
        if value.toString() == 'true' or value.toString() == 'false'
            @BoolValue.push value
            @length = @BoolValue.length
            return super(false)
        @BoolValue.push null
        @length = @BoolValue.length
        super(true)

    pushValueType: (data) =>
        @BoolValue = data.BoolValue
        for item, index in data.IsNull
            @BoolValue[index] = null if item
        @length = @BoolValue.length

    getArray: () =>
        @BoolValue

    get: (index) =>
        if !@IsNull[index]
            @BoolValue[index]
        else
            null

class BytesFieldData extends FieldData
    constructor: (fieldName, type) ->
        super
        @BytesValue = new Array()

    push: (value) =>
        for v in value
            vNumber = Number(v)
            if isNaN(vNumber) or vNumber < 0 or vNumber > 255
                value = null
                break
        @BytesValue.push value
        @length = @BytesValue.length
        super(false)

    pushValueType: (data) =>
        @BytesValue = data.BytesValue
        for item, index in data.IsNull
            @BytesValue[index] = null if item
        @length = @BytesValue.length

    getArray: () =>
        @BytesValue

    get: (index) =>
        if !@IsNull[index]
            @BytesValue[index]
        else
            null

module.exports = FieldData
