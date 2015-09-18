/**
 * User: booster
 * Date: 9/9/12
 * Time: 12:50
 */

package medkit.object {
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

import medkit.collection.ArrayUtil;
import medkit.object.error.CloneNotRegisteredError;

public class ObjectUtil {
    [Inline]
    public static function equals(o1:*, o2:*):Boolean {
        if(o1 === o2) {
            return true;
        }
        else if(o1 is Equalable && o2 is Equalable) {
            var e1:Equalable = o1 as Equalable;
            var e2:Equalable = o2 as Equalable;

            return e1.equals(e2);
        }
        else if(o1 is Array && o2 is Array) {
            var a1:Array = o1 as Array;
            var a2:Array = o2 as Array;

            if(a1.length != a2.length) {
                return false;
            }
            else {
                for(var i:int = 0; i < a1.length; ++i)
                    if(! equals(a1[i], a2[i]))
                        return false;

                return true;
            }
        }
        else if(o1 is Vector && o2 is Vector) {
            var v1:Vector = o1 as Vector;
            var v2:Vector = o2 as Vector;

            if(v1.length != v2.length) {
                return false;
            }
            else {
                for(var j:int = 0; j < v1.length; ++j)
                    if(! equals(v1[j], v2[j]))
                        return false;

                return true;
            }
        }
        else if(o1 is Dictionary && o2 is Dictionary) {
            var d1:Dictionary = o1 as Dictionary;
            var d2:Dictionary = o2 as Dictionary;

            for(var d1Key:Object in d1)
                if(! equals(d1[d1Key], d2[d1Key]))
                    return false;

            for(var d2Key:Object in d2)
                if(! equals(d1[d2Key], d2[d2Key]))
                    return false;

            return true;
        }
        else if(o1 is Point && o2 is Point) {
            var p1:Point = o1 as Point;
            var p2:Point = o2 as Point;

            return p1.equals(p2);
        }
        else if(o1 is Rectangle && o2 is Rectangle) {
            var r1:Rectangle = o1 as Rectangle;
            var r2:Rectangle = o2 as Rectangle;

            return r1.equals(r2);
        }
        // node: typeof() works only for predefined types, so all object subtypes are compared against other object subtypes
        else if(typeof(o1) == typeof(o2)) {
            return o1 == o2;
        }
        else {
            return false;
        }
    }

    [Inline]
    public static function compare(o1:*, o2:*):int {
        if(o1 is Comparable && o2 is Comparable) {
            var e1:Comparable = o1 as Comparable;
            var e2:Comparable = o2 as Comparable;

            return e1.compareTo(e2);
        }
        else if(o1 as Array && o2 as Array) {
            var a1:Array = o1 as Array;
            var a2:Array = o2 as Array;

            if(a1.length < a2.length) {
                return -1;
            }
            else if(a1.length > a2.length) {
                return 1;
            }
            else {
                for(var i:int = 0; i < a1.length; ++i) {
                    var aRes:int = compare(a1[i], a2[i]);

                    if(aRes != 0)
                        return aRes;
                }

                return 0;
            }
        }
        else if(o1 as Vector && o2 as Vector) {
            var v1:Vector = o1 as Vector;
            var v2:Vector = o2 as Vector;

            if(v1.length < v2.length) {
                return -1;
            }
            else if(v1.length > v2.length) {
                return 1;
            }
            else {
                for(var j:int = 0; j < v1.length; ++j) {
                    var vRes:int = compare(v1[j], v2[j]);

                    if(vRes != 0)
                        return vRes;
                }

                return 0;
            }
        }
        else if(o1 is String && o2 is String) {
            var s1:String = o1 as String;
            var s2:String = o2 as String;

            return s1 < s2 ? -1 : s1 > s2 ? 1 : 0;
        }
        else if((o1 is int || o1 is uint || o1 is Number) && (o2 is int || o2 is uint || o2 is Number)) {
            var i1:Number = o1 as Number;
            var i2:Number = o2 as Number;

            return i1 - i2;
        }
        else if((o1 is int || o1 is uint || o1 is Number || o1 is String) && (o2 is int || o2 is uint || o2 is Number || o2 is String)) {
            var x1:String = o1 as String;
            var x2:String = o2 as String;

            return compare(x1, x2);
        }
        else {
            throw new TypeError("objects can not be compared - o1: " + o1 + ", o2: " + o2);
        }
    }

    [Inline]
    public static function hashCode(o:*):int {
        if(o is Hashable) {
            var h:Hashable = o as Hashable;

            return h.hashCode();
        }
        else if(o is int || o is uint || o is Boolean) {
            return int(o);
        }
        else if(o is Number) {
            return int(o) ^ int(Number(o) * 1000000);
        }
        else if(o is String) {
            var s:String    = o as String;
            var c:int       = 0;

            for (var i:int = 0; i < s.length; ++i)
                c = 31 * c + s.charCodeAt(i);

            return c;
        }
        else {
            var str:String = memoryHashString(o);

            return hashCode(str);
        }
    }

    /**
     * Returns memory address hash string by causing an exception to occur and parsing call stack - very expensive.
     *
     * @exampleText Calling this method is expensive!
     * @param o object to get memory hash string of
     * @return memory hash string of the given object
     */
    public static function memoryHashString(o:*):String {
        var memoryHash:String = null;

        try
        {
            FakeClass(o);
        }
        catch (e:Error)
        {
            memoryHash = String(e).replace(/.*([@|\$].*?) to .*$/gi, '$1');
        }

        return memoryHash;
    }

    [Inline]
    public static function clone(o:*, context:CloningContext):* {
        if(o == null) {
            return null;
        }
        else if(o is int || o is uint || o is Number || o is String) {
            return o;
        }
        else if(o is Array) {
            var array:Array = o as Array;

            return cloneArray(array, context);
        }
        else if(o is Point) {
            var point:Point = o as Point;

            return point.clone();
        }
        else if(o is Rectangle) {
            var rect:Rectangle = o as Rectangle;

            return rect.clone();
        }
        else if(o is Cloneable) {
            var cloneable:Cloneable = o as Cloneable;

            return cloneCloneable(cloneable, context);
        }
        else {
            throw new TypeError("Cloned object must be of a basic type or implement Cloneable.");
        }
    }

    [Inline]
    private static function cloneArray(array:Array, context:CloningContext):Array {
        var arrayCopy:Array = null;

        // shallow clone - no context
        if(context == null) {
            arrayCopy = new Array(array.length);

            ArrayUtil.arrayCopy(array, 0, arrayCopy, 0, array.length);
        }
        else {
            // get cloned instance if available
            arrayCopy = context.fetchClone(array);

            // if no cloned instance, create a new one and add to context
            if(arrayCopy == null) {
                var cloningType:CloningType = context.getObjectCloningType(array);

                switch(cloningType) {
                    case CloningType.NullClone:
                        context.registerClone(array, null);
                        break;

                    case CloningType.ShallowClone:
                        arrayCopy = new Array(array.length);
                        context.registerClone(array, arrayCopy);

                        ArrayUtil.arrayCopy(array, 0, arrayCopy, 0, array.length);
                        break;

                    default:
                        arrayCopy = new Array(array.length);
                        context.registerClone(array, arrayCopy);

                        for(var i:int = 0; i < array.length; ++i)
                            arrayCopy[i] = ObjectUtil.clone(array[i], context);
                        break;
                }
            }
        }

        return arrayCopy;
    }

    [Inline]
    private static function cloneCloneable(cloneable:Cloneable, context:CloningContext):Cloneable {
        // shallow clone
        if(context == null)
            return cloneable.clone();

        var clone:Cloneable  = context.fetchClone(cloneable);  // get cloned instance if available

        if(context.isBeingCloned(cloneable)) {
            if(clone == null)
                throw new CloneNotRegisteredError("Instance being cloned not registered - register cloned " +
                                                  "instance inside clone() method using CloningContext.registerClone()");

            return clone;
        }

        // if no cloned instance, create a new one and add it to context
        if(clone == null) {
            context.gatherMetadata(cloneable);

            var cloningType:CloningType = context.getObjectCloningType(cloneable);

            switch(cloningType) {
                case CloningType.NullClone:
                    context.registerClone(cloneable, null);
                    break;

                case CloningType.ShallowClone:
                    context.addPassIsBeingClonedInstance(cloneable);

                    context.beginCloning(cloneable);
                    clone = cloneable.clone(null);
                    context.registerClone(cloneable, clone);
                    context.finishCloning(cloneable);
                    break;

                default:
                    context.addPassIsBeingClonedInstance(cloneable);

                    context.beginCloning(cloneable);
                    clone = cloneable.clone(context);
                    context.finishCloning(cloneable);
                    break;
            }

            if(context.fetchClone(cloneable) !== clone)
                throw new CloneNotRegisteredError("You need to register cloned instance inside clone() " +
                                                  "method using CloningContext.registerClone()");
        }

        return clone;
    }

    [Inline]
    public static function getClass(o:*):Class {
        var clazz:Class = Object(o).constructor;

        return clazz;
    }

    [Inline]
    public static function getFullClassName(className:String):String {
        if(className.lastIndexOf("::") > 0)
            return className;

        var classNames:Vector.<String> = ApplicationDomain.currentDomain.getQualifiedDefinitionNames();

        var count:int = classNames.length;
        for(var i:int = 0; i < count; i++) {
            var fullClassName:String = classNames[i];

            var index:int = fullClassName.lastIndexOf(className);

            // className equals fullClassName
            if(index == 0)
                return fullClassName;

            // className is only a part of fullClassName
            // check if this fullClassName's last section equals className
            var sepIndex:int = fullClassName.lastIndexOf("::");

            if(index >= 0 && index + className.length == fullClassName.length && sepIndex + "::".length == index) {
                //trace(className, "->", fullClassName);
                return fullClassName;
            }
        }

        return null;
    }
}
}

internal class FakeClass {}
