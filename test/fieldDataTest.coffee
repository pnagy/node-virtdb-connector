FieldData = require '../fieldData'

chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

describe "FieldData", ->
    it "createInstance should create the appropriate type", ->
        type = 'STRING'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.StringValue.should.deep.equal []
        type = 'INT32'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.Int32Value.should.deep.equal []
        type = 'INT64'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.Int64Value.should.deep.equal []
        type = 'UINT32'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.UInt32Value.should.deep.equal []
        type = 'UINT64'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.UInt64Value.should.deep.equal []
        type = 'DOUBLE'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.DoubleValue.should.deep.equal []
        type = 'FLOAT'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.FloatValue.should.deep.equal []
        type = 'BOOL'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.BoolValue.should.deep.equal []
        type = 'BYTES'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.BytesValue.should.deep.equal []
        type = 'DATE'
        field = FieldData.createInstance "fieldName", type
        field.FieldName.should.equal 'fieldName'
        field.Type.should.equal type
        field.StringValue.should.deep.equal []

describe "StringFieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'STRING'
        field.push "cica"
        field.push "kutya"
        field.get(0).should.equal "cica"
        field.get(1).should.equal "kutya"
        field.getArray().should.deep.equal ["cica", "kutya"]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'STRING'
        field.pushArray ["cica", "kutya"]
        field.get(0).should.equal "cica"
        field.get(1).should.equal "kutya"
        field.getArray().should.deep.equal ["cica", "kutya"]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'STRING'
        valueType =
            Type: 'STRING'
            StringValue: ["cica", "kutya", ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal "cica"
        field.get(1).should.equal "kutya"
        should.not.exist field.get(2)
        field.getArray().should.deep.equal ["cica", "kutya", null]
        field.length.should.equal 3

describe "Int32FieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'INT32'
        field.push 5
        field.push -2
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        field.getArray().should.deep.equal [5, -2]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'INT32'
        field.pushArray [5, -2]
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        field.getArray().should.deep.equal [5, -2]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'INT32'
        valueType =
            Type: 'INT32'
            Int32Value: [5, -2, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [5, -2, null]
        field.length.should.equal 3

describe "Int64FieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'INT64'
        field.push 5
        field.push -2
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        field.getArray().should.deep.equal [5, -2]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'INT64'
        field.pushArray [5, -2]
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        field.getArray().should.deep.equal [5, -2]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'INT64'
        valueType =
            Type: 'INT64'
            Int64Value: [5, -2, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [5, -2, null]
        field.length.should.equal 3

describe "UInt32FieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'UINT32'
        field.push 5
        field.push 2
        field.get(0).should.equal 5
        field.get(1).should.equal 2
        field.getArray().should.deep.equal [5, 2]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'UINT32'
        field.pushArray [5, -2]
        field.get(0).should.equal 5
        should.not.exist field.get(1)
        field.getArray().should.deep.equal [5, null]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'UINT32'
        valueType =
            Type: 'UINT32'
            UInt32Value: [5, 2, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal 5
        field.get(1).should.equal 2
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [5, 2, null]
        field.length.should.equal 3

describe "UInt64FieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'UINT64'
        field.push 5
        field.push 2
        field.get(0).should.equal 5
        field.get(1).should.equal 2
        field.getArray().should.deep.equal [5, 2]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'UINT64'
        field.pushArray [5, -2]
        field.get(0).should.equal 5
        should.not.exist field.get(1)
        field.getArray().should.deep.equal [5, null]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'UINT64'
        valueType =
            Type: 'UINT64'
            UInt64Value: [5, 2, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal 5
        field.get(1).should.equal 2
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [5, 2, null]
        field.length.should.equal 3

describe "DoubleFieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'DOUBLE'
        field.push 5.1
        field.push 2.23223232
        field.get(0).should.equal 5.1
        field.get(1).should.equal 2.23223232
        field.getArray().should.deep.equal [5.1, 2.23223232]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'DOUBLE'
        field.pushArray [5, -2]
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        field.getArray().should.deep.equal [5, -2]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'DOUBLE'
        valueType =
            Type: 'DOUBLE'
            DoubleValue: [5.1, -2.14, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal 5.1
        field.get(1).should.equal -2.14
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [5.1, -2.14, null]
        field.length.should.equal 3

describe "FloatFieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'FLOAT'
        field.push 5.1
        field.push 2.23223232
        field.get(0).should.equal 5.1
        should.not.exist field.get(1)
        field.getArray().should.deep.equal [5.1, null]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'FLOAT'
        field.pushArray [5, -2]
        field.get(0).should.equal 5
        field.get(1).should.equal -2
        field.getArray().should.deep.equal [5, -2]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'FLOAT'
        valueType =
            Type: 'FLOAT'
            FloatValue: [5.1, -2.14, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal 5.1
        field.get(1).should.equal -2.14
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [5.1, -2.14, null]
        field.length.should.equal 3

describe "BoolFieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'BOOL'
        field.push true
        field.push 'truee'
        field.get(0).should.equal true
        should.not.exist field.get(1)
        field.getArray().should.deep.equal [true, null]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'BOOL'
        field.pushArray [false, true]
        field.get(0).should.equal false
        field.get(1).should.equal true
        field.getArray().should.deep.equal [false, true]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'BOOL'
        valueType =
            Type: 'BOOL'
            BoolValue: [true, false, ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.equal true
        field.get(1).should.equal false
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [true, false, null]
        field.length.should.equal 3

describe "BytesFieldData", ->
    it "should give back values pushed", ->
        field = FieldData.createInstance "fieldName", 'BYTES'
        field.push [2,34,4,123]
        field.push [266]
        field.get(0).should.deep.equal [2,34,4,123]
        should.not.exist field.get(1)
        field.getArray().should.deep.equal [[2,34,4,123], null]
        field.length.should.equal 2

    it "should give back values pushed as array", ->
        field = FieldData.createInstance "fieldName", 'BYTES'
        field.pushArray [[2,34,4,123], [6]]
        field.get(0).should.deep.equal [2,34,4,123]
        field.get(1).should.deep.equal [6]
        field.getArray().should.deep.equal [[2,34,4,123], [6]]
        field.length.should.equal 2

    it "should give back values pushed as well-formed ValueType", ->
        field = FieldData.createInstance "fieldName", 'BYTES'
        valueType =
            Type: 'BYTES'
            BytesValue: [[2,34,4,123], [43, 34], ""]
            IsNull: [false, false, true]
        field.pushValueType valueType
        field.get(0).should.deep.equal [2,34,4,123]
        field.get(1).should.deep.equal [43, 34]
        should.not.exist field.get(2)
        field.getArray().should.deep.equal [[2,34,4,123], [43, 34], null]
        field.length.should.equal 3
