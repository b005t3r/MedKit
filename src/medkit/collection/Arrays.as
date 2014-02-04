/**
 * User: booster
 * Date: 9/9/12
 * Time: 13:33
 */

package medkit.collection {

public class Arrays {
    public static function copyOf(array:Array, capacity:int):Array {
        var copy:Array = new Array(capacity);

        for(var i:int = 0; i < copy.length && i < array.length; ++i)
            copy[i] = array[i];

        return copy;
    }

    public static function arrayCopy(src:Array, srcPos:int, dest:Array, destPos:int, length:int):void {
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
}

}
