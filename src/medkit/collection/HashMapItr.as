/**
 * User: booster
 * Date: 11/17/12
 * Time: 17:19
 */

package medkit.collection {

import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;

public class HashMapItr implements Iterator {
    internal var map:HashMap;

    internal var _next:HashMapEntry;        // next entry to return
    internal var expectedModCount:int;      // For fast-fail
    internal var index:int;                 // current slot
    internal var current:HashMapEntry;      // current entry

    public function HashMapItr(map:HashMap) {
        this.map = map;

        expectedModCount = map.modCount;

        if (map._size > 0) { // advance to first entry
            var t:Array = map.table;

            //noinspection StatementWithEmptyBodyJS
            while (index < t.length && (_next = t[index++]) == null)
                /* do nothing  */;
        }
    }

    public function hasNext():Boolean {
        return _next != null;
    }

    public function next():* {
        throw new DefinitionError("This method is not implemented");
    }

    public function remove():void {
        if (current == null)
            throw new UninitializedError();

        if (map.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        var k:* = current.key;
        current = null;

        map.removeEntryForKey(k);

        expectedModCount = map.modCount;
    }

    protected final function nextEntry():HashMapEntry {
        if (map.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        var e:HashMapEntry = _next;

        if (e == null)
            throw new RangeError();

        if ((_next = e.next) == null) {
            var t:Array = map.table;

            //noinspection StatementWithEmptyBodyJS
            while (index < t.length && (_next = t[index++]) == null)
                /* do nothing  */;
        }

        current = e;

        return e;
    }
}

}
