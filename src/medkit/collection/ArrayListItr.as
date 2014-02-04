/**
 * User: booster
 * Date: 11/16/12
 * Time: 20:43
 */

package medkit.collection {
import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;

public class ArrayListItr implements Iterator {
    internal var list:ArrayList;

    internal var cursor:int;             // index of next element to return
    internal var lastRet:int;            // index of last element returned; -1 if no such
    internal var expectedModCount:int;

    public function ArrayListItr(list:ArrayList) {
        this.list           = list;

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

        if (i >= list.elementData.length)
            throw new ConcurrentModificationError();

        cursor = i + 1;

        return list.elementData[lastRet = i];
    }

    public function remove():void {
        if (lastRet < 0)
            throw new UninitializedError();

        checkForCoModification();

        try {
            list.remove(lastRet);
            cursor              = lastRet;
            lastRet             = -1;
            expectedModCount    = list.modCount;
        }
        catch (e:RangeError) {
            throw new ConcurrentModificationError();
        }
    }

    internal final function checkForCoModification():void {
        if(list.modCount != expectedModCount)
            throw new ConcurrentModificationError();
    }
}

}
