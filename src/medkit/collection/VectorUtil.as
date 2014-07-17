/**
 * User: booster
 * Date: 15/05/14
 * Time: 11:55
 */
package medkit.collection {
public class VectorUtil {
    public static function arrayCopy(src:*, srcPos:int, dest:*, destPos:int, length:int):void {
        if(src == null)                     throw new ArgumentError("Source array must not be null");
        if(dest == null)                    throw new ArgumentError("Destination array must not be null");
        if(srcPos < 0)                      throw new RangeError("Source index must be greater or equal to 0");
        if(destPos < 0)                     throw new RangeError("Destination index must be greater or equal to 0");
        if(length < 0)                      throw new RangeError("Length must be greater or equal to 0");
        if(srcPos + length > src.length)    throw new RangeError("Last source element out of bounds");
        if(destPos + length > dest.length)  throw new RangeError("Last destination element out of bounds");

        if(src != dest || srcPos > destPos) {
            for(var i:int = 0; i < length; ++i)
                dest[i + destPos] = src[i + srcPos];
        }
        else if(srcPos < destPos) {
            for(var j:int = length - 1; j >= 0; --j)
                dest[j + destPos] = src[j + srcPos];
        }
    }

    public static function indexOfValueOfClass(vector:*, clazz:Class):int {
        var count:int = vector.length;
        for(var i:int = 0; i < count; i++)
            if(vector[i] is clazz)
                return i;

        return -1;
    }

    public static function allValuesOfClass(vector:*, clazz:Class, result:*):void {
        var count:int = vector.length;
        for(var i:int = 0; i < count; i++)
            if(vector[i] is clazz)
                result[result.length] = vector[i];
    }

    public static function indexOfValueMatchingCriteria(vector:*, matchCriteria:Function):int {
        var count:int = vector.length;
        for(var i:int = 0; i < count; i++)
            if(matchCriteria(vector[i]))
                return i;

        return -1;
    }
}
}
