/**
 * User: booster
 * Date: 11/16/12
 * Time: 21:49
 */

package medkit.collection {
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.ListIterator;

public class ArrayListSubListListItr implements ListIterator {
    private var list:ArrayListSubList;
    private var cursor:int;
    private var lastRet:int;
    private var expectedModCount:int;

    public function ArrayListSubListListItr(list:ArrayListSubList, index:int) {
        this.list           = list;
        cursor              = index;
        lastRet             = -1;
        expectedModCount    = list.modCount;
    }

    public function hasNext():Boolean {
        return cursor != list.size();
    }

    public function next():* {
        checkForCoModification();

        var i:int = cursor;

        if (i >= list.size())
            throw new RangeError("Iterating beyond last element of this iteration");

        if (list.offset + i >= list.list.elementData.length)
            throw new ConcurrentModificationError();

        cursor = i + 1;

        return list.list.elementData[list.offset + (lastRet = i)];
    }

    public function hasPrevious():Boolean {
        return cursor != 0;
    }

    public function previous():* {
        checkForCoModification();

        var i:int = cursor - 1;

        if (i < 0)
            throw new RangeError("Iterating before first element of this iteration");

        if (list.offset + i >= list.list.elementData.length)
            throw new ConcurrentModificationError();

        cursor = i;

        return list.list.elementData[list.offset + (lastRet = i)];
    }

    public function nextIndex():int {
        return cursor;
    }

    public function previousIndex():int {
        return cursor - 1;
    }

    public function remove():void {
        if (lastRet < 0)
            throw new UninitializedError();

        checkForCoModification();

        try {
            list.removeAt(lastRet);

            cursor              = lastRet;
            lastRet             = -1;
            expectedModCount    = list.list.modCount;
        }
        catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }

    public function set(e:*):void {
        if (lastRet < 0)
            throw new UninitializedError();

        checkForCoModification();

        try {
            list.list.set(list.offset + lastRet, e);
        }
        catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }

    public function add(e:*):void {
        checkForCoModification();

        try {
            var i:int = cursor;
            list.addAt(i, e);
            cursor = i + 1;
            lastRet = -1;
            expectedModCount = list.list.modCount;
        } catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }

    private final function checkForCoModification():void {
        if (expectedModCount != list.list.modCount)
            throw new ConcurrentModificationError();
    }

}

}
