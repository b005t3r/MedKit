/**
 * User: booster
 * Date: 2/10/13
 * Time: 10:18
 */

package medkit.enum {

import flash.errors.IllegalOperationError;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Comparable;
import medkit.object.Equalable;
import medkit.object.Hashable;
import medkit.object.ObjectUtil;

public class Enum implements Equalable, Comparable, Hashable, Cloneable {
    private static const OrderMetadataName:String = "Order";

    private static var allConstantByClass:Object = {};

    private var value:String;

    public static function allEnums(clazz:Class):Array {
        var className:String    = getQualifiedClassName(clazz);
        var allConstants:Array  = allConstantByClass[className];

        if(allConstants == null)
            throw new IllegalOperationError("initEnums() was not called for class " + className);

        return allConstants;
    }

    public static function enumForName(name:String, clazz:Class):Enum {
        var className:String    = getQualifiedClassName(clazz);
        var allConstants:Array  = allConstantByClass[className];

        if(allConstants == null)
            throw new IllegalOperationError("initEnums() was not called for class " + className);

        var count:int = allConstants.length;
        for(var i:int = 0; i < count; ++i) {
            var e:Enum = allConstants[i];

            if(e.value == name)
                return e;
        }

        return null;
    }

    public static function nameForEnum(e:Enum):String { return e.value; }

    protected static function initEnums(clazz:Class):void {
        var type:XML            = describeType(clazz);
        var className:String    = getQualifiedClassName(clazz);
        var allConstants:Array  = allConstantByClass[className];

        if(allConstants != null)
            throw new IllegalOperationError("initEnums() was already called for class " + className);

        // set order is available
        var order:Array = null;

        for each (var metadataXML:XML in type.factory.metadata) {
            if(metadataXML.@name != OrderMetadataName)
                continue;

            if(order == null)
                order = [];

            for each(var argXML:XML in metadataXML.arg)
                order.push(String(argXML.@value));
        }

        // add constant to collection
        if(order == null)
            allConstants = [];
        else
            allConstants = new Array(order.length);

        for each (var constantXML:XML in type.constant) {
            var constant:* = clazz[constantXML.@name];

            constant.value = constantXML.@name;

            var index:int = order != null
                ? order.indexOf(String(constantXML.@name))
                : -1
            ;

            if(index >= 0)
                allConstants[index] = constant;
            else if(order == null)
                allConstants.push(constant);
            else
                throw new UninitializedError(OrderMetadataName + "metadata does not contain all constants declared in " + className);
        }

        if(allConstants.length == 0)
            throw new UninitializedError(className + "does not declare any constant");

        allConstantByClass[className] = allConstants;
    }

    public function allEnums():Array {
        var clazz:Class = ObjectUtil.getClass(this);

        return Enum.allEnums(clazz);
    }

    public function index():int {
        var clazz:Class = ObjectUtil.getClass(this);

        return Enum.allEnums(clazz).indexOf(this);
    }

    public function toString():String {
        return value;
    }

    public function equals(object:Equalable):Boolean {
        var clazz:Class = ObjectUtil.getClass(this);

        if(! (object is clazz))
            return false;

        var allConstants:Array  = Enum.allEnums(clazz);
        var thisIndex:int       = allConstants.indexOf(this);
        var objectIndex:int     = allConstants.indexOf(object);

        return thisIndex == objectIndex;
    }

    public function compareTo(object:Comparable):int {
        var clazz:Class = ObjectUtil.getClass(this);

        if(! (object is clazz))
            throw new ArgumentError("object (" + object + ") is not of class " + clazz);

        var allConstants:Array  = Enum.allEnums(clazz);
        var thisIndex:int       = allConstants.indexOf(this);
        var objectIndex:int     = allConstants.indexOf(object);

        return thisIndex - objectIndex;
    }

    public function hashCode():int {
        return ObjectUtil.hashCode(value);
    }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        return this;
    }
}

}
