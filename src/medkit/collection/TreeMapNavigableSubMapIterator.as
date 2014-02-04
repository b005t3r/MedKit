/**
 * User: booster
 * Date: 12/16/12
 * Time: 15:40
 */

package medkit.collection {

import medkit.collection.error.ConcurrentModificationError;
import medkit.collection.iterator.Iterator;

public class TreeMapNavigableSubMapIterator implements Iterator {
    internal var map:TreeMapNavigableSubMap;
    internal var lastReturned:TreeMapEntry;
    internal var _next:TreeMapEntry;
    internal var fenceKey:*;
    internal var expectedModCount:int;

    public function TreeMapNavigableSubMapIterator(map:TreeMapNavigableSubMap, first:TreeMapEntry, fence:TreeMapEntry) {
        this.map = map;
        expectedModCount = map.m.modCount;
        lastReturned = null;
        _next = first;
        fenceKey = fence == null ? TreeMap.UNBOUNDED : fence.key;
    }

    public function hasNext():Boolean {
        return _next != null && _next.key != fenceKey;
    }

    internal final function nextEntry():TreeMapEntry {
        var e:TreeMapEntry = _next;

        if(e == null || e.key == fenceKey)
            throw new RangeError();

        if(map.m.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        _next = TreeMap.successor(e);
        lastReturned = e;

        return e;
    }

    internal final function prevEntry():TreeMapEntry {
        var e:TreeMapEntry = _next;

        if(e == null || e.key == fenceKey)
            throw new RangeError();

        if(map.m.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        _next = TreeMap.predecessor(e);
        lastReturned = e;

        return e;
    }

    internal final function removeAscending():void {
        if(lastReturned == null)
            throw new UninitializedError();

        if(map.m.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        // deleted entries are replaced by their successors
        if(lastReturned.left != null && lastReturned.right != null)
            _next = lastReturned;

        map.m.deleteEntry(lastReturned);

        lastReturned = null;
        expectedModCount = map.m.modCount;
    }

    internal final function removeDescending():void {
        if(lastReturned == null)
            throw new UninitializedError();

        if(map.m.modCount != expectedModCount)
            throw new ConcurrentModificationError();

        map.m.deleteEntry(lastReturned);

        lastReturned = null;
        expectedModCount = map.m.modCount;
    }

    public function next():* { throw new DefinitionError("abstract method"); }

    public function remove():void  { throw new DefinitionError("abstract method"); }
}

}
