/**
 * User: booster
 * Date: 11/16/12
 * Time: 21:14
 */

package medkit.collection {
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;

public class ArrayListSubList extends AbstractList {
    internal var list:ArrayList;
    internal var parent:AbstractList;
    internal var parentOffset:int;
    internal var offset:int;
    internal var _size:int;

    public function ArrayListSubList(list:ArrayList, parent:AbstractList, offset:int, fromIndex:int, toIndex:int) {
        this.list           = list;
        this.parent         = parent;
        this.parentOffset   = fromIndex;
        this.offset         = offset + fromIndex;
        this._size          = toIndex - fromIndex;
        this.modCount       = list.modCount;
    }

    override public function set(index:int, e:*):* {
        rangeCheck(index);
        checkForCoModification();

        var oldValue:*                      = list.elementData[offset + index];
        list.elementData[offset + index]    = e;

        return oldValue;
    }

    override public function get(index:int):* {
        rangeCheck(index);
        checkForCoModification();

        return list.elementData[offset + index];
    }

    override public function size():int {
        checkForCoModification();

        return _size;
    }

    override public function addAt(index:int, e:*):void {
        rangeCheckForAdd(index);
        checkForCoModification();

        parent.addAt(parentOffset + index, e);
        modCount = parent.modCount;
        _size++;
    }

    override public function removeAt(index:int):* {
        rangeCheck(index);
        checkForCoModification();

        var result:* = parent.removeAt(parentOffset + index);
        modCount = parent.modCount;
        _size--;

        return result;
    }

    override public function removeRange(fromIndex:int, toIndex:int):void {
        checkForCoModification();

        parent.removeRange(parentOffset + fromIndex, parentOffset + toIndex);
        this.modCount = parent.modCount;
        _size -= toIndex - fromIndex;
    }

    override public function addAll(c:Collection):Boolean {
        return addAllAt(_size, c);
    }

    override public function addAllAt(index:int, c:Collection):Boolean {
        rangeCheckForAdd(index);

        var cSize:int = c.size();

        if (cSize == 0)
            return false;

        checkForCoModification();

        parent.addAllAt(parentOffset + index, c);
        modCount = parent.modCount;
        _size += cSize;

        return true;
    }

    override public function iterator():Iterator {
        return listIterator();
    }

    override public function listIterator(index:int = 0):ListIterator {
        return new ArrayListSubListListItr(this, index);
    }

    override public function subList(fromIndex:int, toIndex:int):List {
        list.subListRangeCheck(fromIndex, toIndex, _size);

        return new ArrayListSubList(list, this, offset, fromIndex, toIndex);
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
        return "Index: " + index + ", Size: "+ _size;
    }

    private function checkForCoModification():void {
        if (list.modCount != modCount)
            throw new ConcurrentModificationError();
    }
}

}
