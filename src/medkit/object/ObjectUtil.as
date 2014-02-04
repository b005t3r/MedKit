/**
 * User: booster
 * Date: 9/9/12
 * Time: 12:50
 */

package medkit.object {
import medkit.collection.Arrays;
import medkit.object.error.CloneNotRegisteredError;

public class ObjectUtil {
    public static function equals(o1:*, o2:*):Boolean {
        if(o1 is Equalable && o2 is Equalable) {
            var e1:Equalable = o1 as Equalable;
            var e2:Equalable = o2 as Equalable;

            return e1.equals(e2);
        }
        else if(typeof(o1) == typeof(o2)) {
            return o1 == o2;
        }
        else {
            return false;
        }
    }

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
                    var res:int = compare(a1[i], a2[i]);

                    if(res != 0)
                        return res;
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
            var v1:String = o1 as String;
            var v2:String = o2 as String;

            return compare(v1, v2);
        }
        else {
            throw new TypeError("objects can not be compared - o1: " + o1 + ", o2: " + o2);
        }
    }

    public static function hashCode(o:*):int {
        if(o is Hashable) {
            var h:Hashable = o as Hashable;

            return h.hashCode();
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
        else if(o is Cloneable) {
            var cloneable:Cloneable = o as Cloneable;

            return cloneCloneable(cloneable, context);
        }
        else {
            throw new TypeError("Cloned object must be of a basic type or implement Cloneable.");
        }
    }

    private static function cloneArray(array:Array, context:CloningContext):Array {
        var arrayCopy:Array = null;

        // shallow clone - no context
        if(context == null) {
            arrayCopy = new Array(array.length);

            Arrays.arrayCopy(array, 0, arrayCopy, 0, array.length);
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

                        Arrays.arrayCopy(array, 0, arrayCopy, 0, array.length);
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

    public static function getClass(o:*):Class {
        var clazz:Class = Object(o).constructor;

        return clazz;
    }
}

}

internal class FakeClass {}
