/**
 * User: booster
 * Date: 9/9/12
 * Time: 16:28
 */

package medkit.collection {

import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;

internal class AbstractListItr implements Iterator {
    protected var list:AbstractList;
    protected var cursor:int;
    protected var lastRet:int;
    protected var expectedModCount:int;

    public function AbstractListItr(list:AbstractList) {
        this.list   = list;
        cursor = 0;
        lastRet = -1;
        expectedModCount = list.modCount;
    }

    public function hasNext():Boolean {
        return cursor != list.size();
    }

    public function next():* {
        checkForConcurrentModification();

        try {
            var i:int   = cursor;
            var next:*  = list.get(i);
            lastRet     = i;
            cursor      = i + 1;

            return next;
        } catch (e:RangeError) {
            checkForConcurrentModification();

            throw new RangeError("Iterating beyond last element of this iteration");
        }
    }

    public function remove():void {
        if (lastRet < 0)
            throw new UninitializedError();

        checkForConcurrentModification();

        try {
            list.removeAt(lastRet);

            if (lastRet < cursor)
                cursor--;

            lastRet             = -1;
            expectedModCount    = list.modCount;
        } catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }

    internal function checkForConcurrentModification():void {
        if (list.modCount != expectedModCount)
            throw new ConcurrentModificationError("");
    }
}

}
