/**
 * User: booster
 * Date: 9/9/12
 * Time: 16:28
 */

package medkit.collection {

import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.ListIterator;

internal class AbstractListListItr extends AbstractListItr implements ListIterator {
    public function AbstractListListItr(list:AbstractList, index:int = 0) {
        super(list);

        cursor = index;
    }

    public function hasPrevious():Boolean {
        return cursor != 0;
    }

    public function previous():* {
        checkForConcurrentModification();

        try {
            var i:int           = cursor - 1;
            var previous:*      = list.get(i);
            lastRet = cursor    = i;

            return previous;
        } catch (e:RangeError) {
            checkForConcurrentModification();

            throw new RangeError("Iterating before first element of this iteration");
        }
    }

    public function nextIndex():int {
        return cursor;
    }

    public function previousIndex():int {
        return cursor - 1;
    }

    public function set(e:*):void {
        if (lastRet < 0)
            throw new UninitializedError();

        checkForConcurrentModification();

        try {
            list.set(lastRet, e);

            expectedModCount = list.modCount;
        } catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }

    public function add(e:*):void {
        checkForConcurrentModification();

        try {
            var i:int = cursor;

            list.addAt(i, e);

            lastRet = -1;
            cursor = i + 1;
            expectedModCount = list.modCount;
        } catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }
}

}
