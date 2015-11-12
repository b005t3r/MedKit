/**
 * User: booster
 * Date: 9/9/12
 * Time: 17:18
 */

package medkit.collection {
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;

internal class SubList extends AbstractList {
    internal var l:AbstractList;
    internal var offset:int;
    internal var _size:int;

    public function SubList(list:AbstractList, fromIndex:int, toIndex:int) {
        if (fromIndex < 0)
            throw new RangeError("fromIndex = " + fromIndex);
        if (toIndex > list.size())
            throw new RangeError("toIndex = " + toIndex);
        if (fromIndex > toIndex)
            throw new ArgumentError("fromIndex(" + fromIndex + ") > toIndex(" + toIndex + ")");

        l               = list;
        offset          = fromIndex;
        _size            = toIndex - fromIndex;
        this.modCount   = l.modCount;
    }

    override public function set(index:int, o:*):* {
        rangeCheck(index);
        checkForConcurrentModification();

        return l.set(index + offset, o);
    }

    override public function get (index:int):* {
        rangeCheck(index);
        checkForConcurrentModification();

        return l.get(index + offset);
    }

    override public function size():int {
        checkForConcurrentModification();

        return _size;
    }

    override public function addAt(index:int, o:*):void {
        rangeCheckForAdd(index);
        checkForConcurrentModification();
        l.addAt(index + offset, o);
        this.modCount = l.modCount;
        _size++;
    }

    override public function removeAt(index:int):* {
        rangeCheck(index);
        checkForConcurrentModification();
        var result:* = l.remove(index + offset);
        this.modCount = l.modCount;
        _size--;

        return result;
    }

    override public function addAll(c:Collection):Boolean {
        return addAllAt(_size, c);
    }

    override public function addAllAt(index:int, c:Collection):Boolean {
        rangeCheckForAdd(index);
        var cSize:int = c.size();

        if(cSize == 0)
            return false;

        checkForConcurrentModification();
        l.addAllAt(offset + index, c);
        this.modCount = l.modCount;
        _size += cSize;

        return true;
    }

    override public function iterator():Iterator  {
        return listIterator();
    }

    override public function listIterator(index:int = 0):ListIterator {
        checkForConcurrentModification();
        rangeCheckForAdd(index);

        return new SubListIterator(this, index);
    }

    override internal function removeRangeInternal(fromIndex:int, toIndex:int):void {
        checkForConcurrentModification();
        l.removeRangeInternal(fromIndex + offset, toIndex + offset);
        this.modCount = l.modCount;
        _size -= (toIndex - fromIndex);
    }

    override public function subList(fromIndex:int, toIndex:int):List {
        return new SubList(this, fromIndex, toIndex);
    }

    private function rangeCheck(index:int):void {
        if (index < 0 || index >= _size)
            throw new RangeError(outOfBoundsMsg(index));
    }

    private function rangeCheckForAdd(index:int):void {
        if (index < 0 || index > _size)
            throw new RangeError(outOfBoundsMsg(index));
    }

    private function outOfBoundsMsg(index:int):String {
        return "Index: " + index + ", Size: " + size;
    }

    private function checkForConcurrentModification():void {
        if (this.modCount != l.modCount)
            throw new ConcurrentModificationError();
    }
}

}
