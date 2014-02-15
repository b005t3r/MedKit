/**
 * User: booster
 * Date: 9/9/12
 * Time: 13:20
 */

package medkit.string {

import medkit.collection.Arrays;

public class StringBuilder {
    // TODO: should be backed up by ByteArray instead of Array
    private var value:Array;
    private var count:int;

    public function StringBuilder(capacity:int = 32) {
        value = new Array(capacity);
        count = 0;
    }

    public function length():int {
        return count;
    }

    public function capacity():int {
        return value.length;
    }

    public function ensureCapacity(minimumCapacity:int):void {
        if(minimumCapacity > value.length)
            expandCapacity(minimumCapacity);
    }

    public function trimToSize():void {
        //if (count < value.length)
        //    value = Arrays.copyOf(value, count);
        value.length = count;
    }

    public function setLength(newLength:int):void {
        if(newLength < 0)
            throw new RangeError("newLength is below zero: " + newLength);

        if(newLength > value.length)
            expandCapacity(newLength);

        if(count < newLength) {
            var oldCount:int = count;

            for(; count < newLength; count++)
                value[count] = 0;

            count = oldCount;
        }
        else {
            count = newLength;
        }
    }

    public function charCodeAt(index:int):int {
        if((index < 0) || (index >= count))
            throw new RangeError("index out of bounds: " + index);

        return value[index];
    }

    public function append(o:*):StringBuilder {
        if(o is StringBuilder)
            return appendStringBuilder(o);
        else
            return appendObject(o);
    }

    public function toString():String {
        value.length = count;

        return String.fromCharCode.apply(null, value);
    }

    protected function expandCapacity(minimumCapacity:int):void {
        var newCapacity:int = (value.length + 1) * 2;

        if(minimumCapacity > newCapacity)
            newCapacity = minimumCapacity;

        value.length = newCapacity;
    }

    protected function appendObject(o:*):StringBuilder {
        var str:String = o.toString();

        ensureCapacity(count + str.length);

        for(var i:int = 0; i < str.length; ++i)
            value[i + count] = str.charCodeAt(i);

        count += str.length;

        return this;
    }

    protected function appendStringBuilder(builder:StringBuilder):StringBuilder {
        var length:int = builder.length();

        ensureCapacity(count + length);

        for(var i:int = 0; i < length; ++i)
            value[i + count] = builder.charCodeAt(i);

        count += length;

        return this;
    }
}

}
