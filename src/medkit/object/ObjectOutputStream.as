/**
 * User: booster
 * Date: 19/05/14
 * Time: 9:44
 */
package medkit.object {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import medkit.enum.Enum;

public class ObjectOutputStream {
    private var _jsonData:Object                = { serializedObjects : [], globalKeys : {} };
    private var _savedObjectIndexes:Dictionary  = new Dictionary();
    private var _context:Object                 = null;

    public function get jsonData():Object { return _jsonData; }

    public function saveToJSONString():String {
        return JSON.stringify(_jsonData);
    }

    public function saveToFileStream(stream:FileStream, closeStream:Boolean = true):void {
        var string:String = saveToJSONString();

        stream.writeUnsignedInt(string.length);
        stream.writeUTFBytes(string);

        if(closeStream)
            stream.close();
    }

    public function saveToFile(file:File):void {
        if(file.isDirectory)
            throw new ArgumentError("file cannot be a directory");

        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);

        saveToFileStream(stream);
    }

    public function writeBoolean(value:Boolean, key:String):void {
        writeAny(value, key);
    }

    public function writeInt(value:int, key:String):void {
        writeAny(value, key);
    }

    public function writeUnsignedInt(value:uint, key:String):void {
        writeAny(value, key);
    }

    public function writeNumber(value:Number, key:String):void {
        writeAny(value, key);
    }

    public function writeString(value:String, key:String):void {
        writeAny(value, key);
    }

    public function writeObject(value:Object, key:String):void {
        writeAny(value, key);
    }

    protected function writeAny(value:*, key:String):void {
        var obj:Object;

        if(value == null) {
            obj = { thisIsANullObject : true };

            if(_context == null)    _jsonData.globalKeys[key] = obj;
            else                    _context.members[key] = obj;
        }
        else if(typeof(value) != "object") {
            //if(value is Number && ((value as Number) * 0) != 0)
            //    throw new ArgumentError("impossible to save NaN, Infinity or -Infinity values");

            if(value is Number && value != value) {
                if(_context == null)    _jsonData.globalKeys[key]   = { thisIsNaN : true };
                else                    _context.members[key]       = { thisIsNaN : true };

                return;
            }
            else if(value is Number && ((value as Number) * 0) < 0) {
                if(_context == null)    _jsonData.globalKeys[key]   = { thisIsNegInf : true };
                else                    _context.members[key]       = { thisIsNegInf : true };

                return;
            }
            else if(value is Number && ((value as Number) * 0) > 0) {
                if(_context == null)    _jsonData.globalKeys[key]   = { thisIsPosInf : true };
                else                    _context.members[key]       = { thisIsPosInf : true };

                return;
            }

            obj = value;

            if(_context == null)    _jsonData.globalKeys[key] = obj;
            else                    _context.members[key] = obj;
        }
        else if(value is Enum) {
            var e:Enum = value as Enum;

            if(_context == null)    _jsonData.globalKeys[key] = { thisIsAnEnum : Enum.nameForEnum(e), className : getQualifiedClassName(value) };
            else                    _context.members[key] = { thisIsAnEnum : Enum.nameForEnum(e), className : getQualifiedClassName(value) };
        }
        else if(_savedObjectIndexes[value] == null) {
            obj = { className : getQualifiedClassName(value), members : {}};

            _savedObjectIndexes[value] = _jsonData.serializedObjects.length;
            _jsonData.serializedObjects[_jsonData.serializedObjects.length] = obj;

            if(_context == null)    _jsonData.globalKeys[key] = { objectIndex : _jsonData.serializedObjects.length - 1 };
            else                    _context.members[key] = { objectIndex : _jsonData.serializedObjects.length - 1 };

            var oldContext:Object = _context;
            _context              = obj;

            if(value is Array) {
                var arr:Array = value as Array;

                var count:int = arr.length;
                for(var i:int = 0; i < count; ++i) {
                    var arrElem:*       = arr[i];
                    var arrKey:String   = String(i);

                    if(arrElem is Number && ((arrElem as Number) * 0) != 0) throw new ArgumentError("impossible to save NaN, Infinity or -Infinity values");
                    else if(typeof(arrElem) != "object")                    _context.members[arrKey] = arrElem;
                    else if(_savedObjectIndexes[arrElem] != null)           _context.members[arrKey] = { objectIndex : _savedObjectIndexes[arrElem] };
                    else                                                    writeAny(arrElem, arrKey);
                }
            }
            else if(value is Dictionary) {
                var dict:Dictionary = value as Dictionary;

                for(var dictKey:Object in dict) {
                    if(dictKey is String == false)
                        throw new TypeError("all keys of serialized Dictionary has to be Strings");

                    var dictElem:* = dict[dictKey];

                    if(dictElem is Number && ((dictElem as Number) * 0) != 0)   throw new ArgumentError("impossible to save NaN, Infinity or -Infinity values");
                    else if(typeof(dictElem) != "object")                       _context.members[dictKey] = dictElem;
                    else if(_savedObjectIndexes[dictElem] != null)              _context.members[dictKey] = { objectIndex : _savedObjectIndexes[dictElem] };
                    else                                                        writeAny(dictElem, dictKey as String);
                }
            }
            else if(ObjectUtil.getClass(value) == Object) {
                var o:Object = value as Object;

                for(var oKey:String in o) {
                    var oElem:* = o[oKey];

                    if(oElem is Number && ((oElem as Number) * 0) != 0) throw new ArgumentError("impossible to save NaN, Infinity or -Infinity values");
                    else if(typeof(oElem) != "object")                  _context.members[oKey] = oElem;
                    else if(_savedObjectIndexes[oElem] != null)         _context.members[oKey] = { objectIndex : _savedObjectIndexes[oElem] };
                    else                                                writeAny(oElem, oKey);
                }
            }
            else if(value is Serializable) {
                var serializable:Serializable = value as Serializable;

                serializable.writeObject(this);
            }
            else {
                throw new TypeError("value '" + value + "' for key '" + key + "' is not an Array or Dictionary and does not implement 'Serializable'");
            }

            _context = oldContext;
        }
        else {
            var index:int = _savedObjectIndexes[value];

            if(_context != null)
                _context.members[key] = { objectIndex : index };
        }
    }
}
}
