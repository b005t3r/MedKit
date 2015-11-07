/**
 * User: booster
 * Date: 11/16/12
 * Time: 17:35
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.ObjectUtil;

public class ArrayList extends AbstractList {
    internal var elementData:Array;
    private var _size:int;

    public function ArrayList(capacity:int = 10) {
        if (capacity < 0)
            throw new ArgumentError("Illegal Capacity: " + capacity);

        this.elementData = new Array(capacity);
    }

    public function trimToSize():void {
        modCount++;

        //var oldCapacity:int = elementData.length;

        //if (_size < oldCapacity)
        //    elementData = Arrays.copyOf(elementData, _size);
        elementData.length = _size;
    }

    public final function ensureCapacity(minCapacity:int):void {
        modCount++;

        var oldCapacity:int = elementData.length;

        if (minCapacity > oldCapacity) {
            var newCapacity:int = (oldCapacity * 3) / 2 + 1;

            if (newCapacity < minCapacity)
                newCapacity = minCapacity;

            // minCapacity is usually close to size, so this is a win:
            //elementData = Arrays.copyOf(elementData, newCapacity);
            elementData.length = newCapacity;
        }
    }

    override public function size():int {
        return _size;
    }

    override public function isEmpty():Boolean {
        return _size == 0;
    }

    override public function contains(o:*):Boolean {
        return indexOf(o) >= 0;
    }

    override public function indexOf(o:*):int {
        if (o == null) {
            for(var i:int = 0; i < _size; ++i)
                if (elementData[i] == null)
                    return i;
        }
        else {
            for (var j:int = 0; j < _size; ++j)
                if (ObjectUtil.equals(o, elementData[j]))
                    return j;
        }

        return -1;
    }

    override public function lastIndexOf(o:*):int {
        if (o == null) {
            for (var i:int = _size - 1; i >= 0; --i)
                if (elementData[i] == null)
                    return i;
        }
        else {
            for (var j:int = _size - 1; j >= 0; --j)
                if (ObjectUtil.equals(o, elementData[j]))
                    return j;
        }

        return -1;
    }

    override public function clone(cloningContext:CloningContext = null):Cloneable {
        if(cloningContext != null && cloningContext.isBeingCloned(this))
            return cloningContext.fetchClone(this);

        var clone:ArrayList = cloningContext == null
                ? new ArrayList(size())
                : cloningContext.isCloneRegistered(this)
                    ? cloningContext.fetchClone(this)
                    : cloningContext.registerClone(this, new ArrayList(size()))
        ;

        clone._size = _size;

        for(var i:int = 0; i < size(); ++i)
            clone.elementData[i] = cloningContext != null ? ObjectUtil.clone(this.elementData[i], cloningContext) : this.elementData[i];

        return clone;
    }

    override public function readObject(input:ObjectInputStream):void {
        _size       = input.readInt("size");
        elementData = input.readObject("elementData") as Array;
    }

    override public function writeObject(output:ObjectOutputStream):void {
        output.writeInt(_size, "size");
        output.writeObject(elementData, "elementData");
    }

    override public function toArray():Array {
        return ArrayUtil.copyOf(elementData, _size);
    }

    override public function get (index:int):* {
        rangeCheck(index);

        return elementData[index];
    }

    override public function set (index:int, o:*):* {
        rangeCheck(index);

        var oldValue:*      = elementData[index];
        elementData[index]  = o;

        return oldValue;
    }

    override public function add(o:*):Boolean {
        ensureCapacity(_size + 1);  // Increments modCount!!
        elementData[_size++] = o;

        return true;
    }

    override public function addAt(index:int, o:*):void {
        rangeCheckForAdd(index);

        ensureCapacity(_size + 1);  // Increments modCount!!

        ArrayUtil.arrayCopy(elementData, index, elementData, index + 1, _size - index);
        elementData[index] = o;
        _size++;
    }

    override public function remove(o:*):Boolean {
        if (o == null) {
            for (var i:int = 0; i < _size; ++i)
                if (elementData[i] == null) {
                    fastRemove(i);
                        return true;
            }
        }
        else {
            for (var j:int = 0; j < _size; ++j)
                if (ObjectUtil.equals(o, elementData[j])) {
                    fastRemove(j);
                        return true;
            }
        }

        return false;
    }

    override public function removeAt(index:int):* {
        rangeCheck(index);

        modCount++;
        var oldValue:* = elementData[index];

        var numMoved:int = _size - index - 1;

        if (numMoved > 0)
            ArrayUtil.arrayCopy(elementData, index + 1, elementData, index, numMoved);

        elementData[--_size] = null; // Let gc do its work

        return oldValue;
    }

    override public function clear():void {
        modCount++;

        // Let gc do its work
        for (var i:int = 0; i < _size; ++i)
            elementData[i] = null;

        _size = 0;
    }

    override public function addAll(c:Collection):Boolean {
        if(c.isEmpty())
            return false;

        var numNew:int = c.size();
        var e:Iterator = c.iterator();

        ensureCapacity(_size + numNew);  // Increments modCount

        while (e.hasNext())
            elementData[_size++] = e.next();

        return true;
    }

    override public function addAllAt(index:int, c:Collection):Boolean {
        rangeCheckForAdd(index);

        if(c.isEmpty())
            return false;

        var numNew:int      = c.size();
        var numMoved:int    = _size - index;
        var e:Iterator      = c.iterator();

        ensureCapacity(_size + numNew);  // Increments modCount

        ArrayUtil.arrayCopy(elementData, index, elementData, index + numNew, numMoved);

        while (e.hasNext())
            elementData[index++] = e.next();

        _size += numNew;

        return true;
    }

    override public function removeAll(c:Collection):Boolean {
        return batchRemove(c, false);
    }

    override public function retainAll(c:Collection):Boolean {
        return batchRemove(c, true);
    }

    override public function iterator():Iterator {
        return new ArrayListItr(this);
    }

    override public function listIterator(index:int = 0):ListIterator {
        return new ArrayListListItr(this, index);
    }

    override public function removeRange(fromIndex:int, toIndex:int):void {
        subListRangeCheck(fromIndex, toIndex, size());

        modCount++;
        var numMoved:int = _size - toIndex;

        ArrayUtil.arrayCopy(elementData, toIndex, elementData, fromIndex, numMoved);

        // Let gc do its work
        var newSize:int = _size - (toIndex - fromIndex);

        while (_size != newSize)
            elementData[--_size] = null;
    }

    private final function batchRemove(c:Collection, complement:Boolean):Boolean {
        var r:int = 0, w:int = 0, modified:Boolean = false;

        for (; r < _size; r++)
            if (c.contains(elementData[r]) == complement)
                elementData[w++] = elementData[r];

        if (r != _size) {
            ArrayUtil.arrayCopy(elementData, r, elementData, w, _size - r);
            w += _size - r;
        }

        if (w != _size) {
            for (var i:int = w; i < _size; i++)
                elementData[i] = null;

            modCount   += _size - w;
            _size       = w;
            modified    = true;
        }

        return modified;
    }

    private final function fastRemove(index:int):void {
        modCount++;

        var numMoved:int = _size - index - 1;

        if(numMoved > 0)
            ArrayUtil.arrayCopy(elementData, index + 1, elementData, index, numMoved);

        elementData[--_size] = null; // Let gc do its work
    }

    private final function rangeCheck(index:int):void {
        if(index >= _size)
            throw new RangeError(outOfBoundsMsg(index));
    }

    private final function rangeCheckForAdd(index:int):void {
        if (index > _size || index < 0)
            throw new RangeError(outOfBoundsMsg(index));
    }

    /**
     * Constructs an IndexOutOfBoundsException detail message.
     * Of the many possible refactorings of the error handling code,
     * this "outlining" performs best with both server and client VMs.
     */
    private final function outOfBoundsMsg(index:int):String {
        return "Index: "+index+", Size: "+size;
    }
}

}
