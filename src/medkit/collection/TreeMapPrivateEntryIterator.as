/**
 * User: booster
 * Date: 12/16/12
 * Time: 11:55
 */

package medkit.collection {

import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;

public class TreeMapPrivateEntryIterator implements Iterator {
    protected var map:TreeMap;
    protected var _next:TreeMapEntry;
    protected var lastReturned:TreeMapEntry;
    protected var expectedModCount:int;

    public function TreeMapPrivateEntryIterator(map:TreeMap, first:TreeMapEntry) {
        this.map            = map;

        expectedModCount    = map.modCount;
        lastReturned        = null;
        _next               = first;
    }

    public function next():* {
        throw new DefinitionError("this method needs to be implemented")
    }

    public function hasNext():Boolean {
        return _next != null;
    }

    public function remove():void {
        if (lastReturned == null)
            throw new UninitializedError();

        if (map.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        // deleted entries are replaced by their successors
        if (lastReturned.left != null && lastReturned.right != null)
            _next = lastReturned;

        map.deleteEntry(lastReturned);

        expectedModCount = map.modCount;
        lastReturned = null;
    }

    protected final function nextEntry():TreeMapEntry {
        var e:TreeMapEntry = _next;

        if (e == null)
            throw new RangeError("iterating over the last element of this map");

        if (map.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        _next = TreeMap.successor(e);
        lastReturned = e;

        return e;
    }

    protected final function prevEntry():TreeMapEntry {
        var e:TreeMapEntry = _next;

        if (e == null)
            throw new RangeError("iterating before the first element of this map");

        if (map.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        _next = TreeMap.predecessor(e);
        lastReturned = e;

        return e;
    }
}

}
