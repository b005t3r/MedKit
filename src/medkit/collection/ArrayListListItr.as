/**
 * User: booster
 * Date: 11/16/12
 * Time: 20:59
 */

package medkit.collection {
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.ListIterator;

public class ArrayListListItr extends ArrayListItr implements ListIterator {
    public function ArrayListListItr(list:ArrayList, index:int) {
        super (list);
        cursor = index;
    }

    public function hasPrevious():Boolean {
        return cursor != 0;
    }

    public function nextIndex():int {
        return cursor;
    }

    public function previousIndex():int {
        return cursor - 1;
    }

    public function previous():* {
        checkForCoModification();

        var i:int = cursor - 1;

        if (i < 0)
            throw new RangeError("Iterating before first element of this iteration");

        if (i >= list.elementData.length)
            throw new ConcurrentModificationError();

        cursor = i;

        return list.elementData[lastRet = i];
    }

    public function set(e:*):void {
        if (lastRet < 0)
            throw new UninitializedError();

        checkForCoModification();

        try {
            list.set(lastRet, e);
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

            cursor              = i + 1;
            lastRet             = -1;
            expectedModCount    = list.modCount;
        }
        catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }
}

}
