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
import flash.utils.getDefinitionByName;

import medkit.enum.Enum;

public class ObjectInputStream {
    private var _jsonData:Object;
    private var _loadedObjectsByIndex:Dictionary    = new Dictionary();
    private var _context:Object                     = null;

    public static function readFromJSONString(jsonString:String):ObjectInputStream {
        return new ObjectInputStream(JSON.parse(jsonString));
    }

    public static function readFromFileStream(stream:FileStream, closeStream:Boolean = true):ObjectInputStream {
        var retVal:ObjectInputStream = readFromJSONString(stream.readUTF());

        if(closeStream)
            stream.close();

        return retVal;
    }

    public static function readFromFile(file:File):ObjectInputStream {
        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.READ);

        return readFromFileStream(stream);
    }

    public function ObjectInputStream(jsonData:Object) {
        _jsonData = jsonData;
    }

    public function readBoolean(key:String):Boolean {
        var retVal:* = readAny(key);

        if(retVal is Boolean == false)
            throw new TypeError("value for key '" + key + "' is not a Boolean");

        return retVal;
    }

    public function readInt(key:String):int {
        var retVal:* = readAny(key);

        if(retVal is int == false)
            throw new TypeError("value for key '" + key + "' is not an int");

        return retVal;
    }

    public function readUnsignedInt(key:String):uint {
        var retVal:* = readAny(key);

        if(retVal is uint == false)
            throw new TypeError("value for key '" + key + "' is not an uint");

        return retVal;
    }

    public function readNumber(key:String):Number {
        var retVal:* = readAny(key);

        if(retVal is Number == false)
            throw new TypeError("value for key '" + key + "' is not a Number");

        return retVal;
    }

    public function readString(key:String):String {
        var retVal:* = readAny(key);

        if(retVal is String == false)
            throw new TypeError("value for key '" + key + "' is not a String");

        return retVal;
    }

    public function readObject(key:String):Object {
        var retVal:Object = readAny(key);

        if(retVal != null && retVal is Object == false)
            throw new TypeError("value for key '" + key + "' is not an Object");

        return retVal;
    }

    protected function readAny(key:String):* {
        var obj:* = _context == null ? _jsonData.globalKeys[key] : _context.members[key];

        if(obj == null)
            throw new ArgumentError("object for key '" + key + "' does not exist");

        if(typeof(obj) != "object")
            return obj;

        if(ObjectUtil.getClass(obj)) {
            if(obj.hasOwnProperty("thisIsANullObject")) { return null;}
            else if(obj.hasOwnProperty("thisIsNaN"))    { return NaN;}
            else if(obj.hasOwnProperty("thisIsNegInf")) { return -Infinity;}
            else if(obj.hasOwnProperty("thisIsPosInf")) { return Infinity;}
            else if(obj.hasOwnProperty("thisIsAnEnum")) {
                var enumClass:Class = getDefinitionByName(obj.className) as Class;

                return Enum.enumForName(obj.thisIsAnEnum, enumClass);
            }
        }

        var index:int = obj.objectIndex;
        obj = _loadedObjectsByIndex[index];

        if(obj != null)
            return obj;

        var oldContext:Object = _context;

        _context                = _jsonData.serializedObjects[index];
        var clazz:Class         = getDefinitionByName(_context.className) as Class;
        var tmpInstance:*       = new clazz();
        var retVal:Object;

        if(clazz == Array) {
            var arr:Array = [];
            _loadedObjectsByIndex[index] = arr;

            for (var arrKey:String in _context.members) {
                if(isNaN(Number(arrKey)))
                    throw new Error("serialized Array member's key can not be converted to an index: " + arrKey);

                var arrIndex:int = int(arrKey);

                if(arr.length <= arrIndex)
                    arr.length = arrIndex + 1;

                var arrElem:* = _context.members[arrKey];

                if(typeof(arrElem) != "object") {
                    arr[arrIndex] = arrElem;
                    continue;
                }

                var arrElemIndex:int = arrElem.objectIndex;
                arrElem = _loadedObjectsByIndex[arrElemIndex];

                if(arrElem != null) {
                    arr[arrIndex] = arrElem;
                    continue;
                }

                arrElem = readAny(arrKey);

                _loadedObjectsByIndex[arrElemIndex] = arrElem;
                arr[arrIndex] = arrElem;
            }

            retVal = arr;
        }
        else if(clazz == Dictionary || clazz == Object) {
            var dict:Dictionary = new Dictionary();
            _loadedObjectsByIndex[index] = dict;

            for (var dictKey:String in _context.members) {
                var dictElem:* = _context.members[dictKey];

                if(typeof(dictElem) != "object") {
                    dict[dictKey] = dictElem;
                    continue;
                }

                var dictElemIndex:int = dictElem.objectIndex;
                dictElem = _loadedObjectsByIndex[dictElemIndex];

                if(dictElem != null) {
                    dict[dictKey] = dictElem;
                    continue;
                }

                dictElem = readAny(dictKey);

                _loadedObjectsByIndex[dictElemIndex] = dictElem;
                dict[dictKey] = dictElem;
            }

            retVal = dict;
        }
        else if(tmpInstance is Serializable) {
            var serializable:Serializable = tmpInstance as Serializable;
            _loadedObjectsByIndex[index] = serializable;
            serializable.readObject(this);

            retVal = serializable;
        }
        else {
            throw new TypeError("class '" + clazz + "' for key '" + key + "' does not implement 'Serializable' (how is that even possible?)");
        }

        _context = oldContext;

        return retVal;
    }
}
}
