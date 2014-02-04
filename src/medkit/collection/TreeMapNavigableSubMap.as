/**
 * User: booster
 * Date: 12/16/12
 * Time: 13:05
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.Comparator;

public class TreeMapNavigableSubMap extends AbstractMap implements NavigableMap {
    internal var m:TreeMap;

    internal var lo:*, hi:*;
    internal var fromStart:Boolean, toEnd:Boolean;
    internal var loInclusive:Boolean, hiInclusive:Boolean;

    internal var _descendingMapView:NavigableMap;
    internal var _entrySetView:TreeMapNavigableSubMapEntrySetView;
    internal var _navigableKeySetView:TreeMapKeySet;

    public function TreeMapNavigableSubMap(m:TreeMap, fromStart:Boolean, lo:*, loInclusive:Boolean, toEnd:Boolean, hi:*, hiInclusive:Boolean) {
        if(!fromStart && !toEnd) {
            if(m.compare(lo, hi) > 0)
                throw new ArgumentError("fromKey > toKey");
        }
        else {
            if(!fromStart) // type check
                m.compare(lo, lo);

            if(!toEnd)
                m.compare(hi, hi);
        }

        this.m = m;
        this.fromStart = fromStart;
        this.lo = lo;
        this.loInclusive = loInclusive;
        this.toEnd = toEnd;
        this.hi = hi;
        this.hiInclusive = hiInclusive;
    }

    internal function tooLow(key:*):Boolean {
        if(!fromStart) {
            var c:int = m.compare(key, lo);
            if(c < 0 || (c == 0 && !loInclusive))
                return true;
        }
        return false;
    }

    internal function tooHigh(key:*):Boolean {
        if(!toEnd) {
            var c:int = m.compare(key, hi);
            if(c > 0 || (c == 0 && !hiInclusive))
                return true;
        }
        return false;
    }

    internal function inRange(key:*):Boolean {
        return !tooLow(key) && !tooHigh(key);
    }

    internal function inClosedRange(key:*):Boolean {
        return (fromStart || m.compare(key, lo) >= 0)
            && (toEnd || m.compare(hi, key) >= 0);
    }

    internal function inRangeInclusive(key:*, inclusive:Boolean):Boolean {
        return inclusive ? inRange(key) : inClosedRange(key);
    }

    internal function absLowest():TreeMapEntry {
        var e:TreeMapEntry =
            (fromStart ? m.getFirstEntry() :
                (loInclusive ? m.getCeilingEntry(lo) :
                    m.getHigherEntry(lo)));
        return (e == null || tooHigh(e.key)) ? null : e;
    }

    internal function absHighest():TreeMapEntry {
        var e:TreeMapEntry =
            (toEnd ? m.getLastEntry() :
                (hiInclusive ? m.getFloorEntry(hi) :
                    m.getLowerEntry(hi)));
        return (e == null || tooLow(e.key)) ? null : e;
    }

    internal function absCeiling(key:*):TreeMapEntry {
        if(tooLow(key))
            return absLowest();
        var e:TreeMapEntry = m.getCeilingEntry(key);
        return (e == null || tooHigh(e.key)) ? null : e;
    }

    internal function absHigher(key:*):TreeMapEntry {
        if(tooLow(key))
            return absLowest();

        var e:TreeMapEntry = m.getHigherEntry(key);
        return (e == null || tooHigh(e.key)) ? null : e;
    }

    internal function absFloor(key:*):TreeMapEntry {
        if(tooHigh(key))
            return absHighest();
        var e:TreeMapEntry = m.getFloorEntry(key);
        return (e == null || tooLow(e.key)) ? null : e;
    }

    internal function absLower(key:*):TreeMapEntry {
        if(tooHigh(key))
            return absHighest();
        var e:TreeMapEntry = m.getLowerEntry(key);
        return (e == null || tooLow(e.key)) ? null : e;
    }

    /** Returns the absolute high fence for ascending traversal */
    internal function absHighFence():TreeMapEntry {
        return (toEnd ? null : (hiInclusive ?
            m.getHigherEntry(hi) :
            m.getCeilingEntry(hi)));
    }

    /** Return the absolute low fence for descending traversal  */
    internal function absLowFence():TreeMapEntry {
        return (fromStart ? null : (loInclusive ?
            m.getLowerEntry(lo) :
            m.getFloorEntry(lo)));
    }

    // Abstract methods defined in ascending vs descending classes
    // These relay to the appropriate absolute versions

    internal function subLowest():TreeMapEntry { throw new DefinitionError("abstract method"); }

    internal function subHighest():TreeMapEntry { throw new DefinitionError("abstract method"); }

    internal function subCeiling(key:*):TreeMapEntry { throw new DefinitionError("abstract method"); }

    internal function subHigher(key:*):TreeMapEntry { throw new DefinitionError("abstract method"); }

    internal function subFloor(key:*):TreeMapEntry { throw new DefinitionError("abstract method"); }

    internal function subLower(key:*):TreeMapEntry { throw new DefinitionError("abstract method"); }

    /** Returns ascending iterator from the perspective of this submap */
    internal function keyIterator():Iterator { throw new DefinitionError("abstract method"); }

    /** Returns descending iterator from the perspective of this submap */
    internal function descendingKeyIterator():Iterator { throw new DefinitionError("abstract method"); }

    override public function isEmpty():Boolean {
        return (fromStart && toEnd) ? m.isEmpty() : entrySet().isEmpty();
    }

    override public function size():int {
        return (fromStart && toEnd) ? m.size() : entrySet().size();
    }

    override public function containsKey(key:*):Boolean {
        return inRange(key) && m.containsKey(key);
    }

    override public function put(key:*, value:*):* {
        if(!inRange(key))
            throw new RangeError("key out of range");

        return m.put(key, value);
    }

    override public function get(key:*):* {
        return !inRange(key) ? null : m.get(key);
    }

    public function remove(key:*):* {
        return !inRange(key) ? null : m.remove(key);
    }

    public function ceilingEntry(key:*):MapEntry {
        return TreeMap.exportEntry(subCeiling(key));
    }

    public function ceilingKey(key:*):* {
        return TreeMap.keyOrNull(subCeiling(key));
    }

    public function higherEntry(key:*):MapEntry {
        return TreeMap.exportEntry(subHigher(key));
    }

    public function higherKey(key:*):* {
        return TreeMap.keyOrNull(subHigher(key));
    }

    public function floorEntry(key:*):MapEntry {
        return TreeMap.exportEntry(subFloor(key));
    }

    public function floorKey(key:*):* {
        return TreeMap.keyOrNull(subFloor(key));
    }

    public function lowerEntry(key:*):MapEntry {
        return TreeMap.exportEntry(subLower(key));
    }

    public function lowerKey(key:*):* {
        return TreeMap.keyOrNull(subLower(key));
    }

    public function firstKey():* {
        return TreeMap.key(subLowest());
    }

    public function lastKey():* {
        return TreeMap.key(subHighest());
    }

    public function firstEntry():MapEntry {
        return TreeMap.exportEntry(subLowest());
    }

    public function lastEntry():MapEntry {
        return TreeMap.exportEntry(subHighest());
    }

    public function pollFirstEntry():MapEntry {
        var e:TreeMapEntry = subLowest();
        var result:MapEntry = TreeMap.exportEntry(e);

        if(e != null)
            m.deleteEntry(e);

        return result;
    }

    public function pollLastEntry():MapEntry {
        var e:TreeMapEntry = subHighest();
        var result:MapEntry = TreeMap.exportEntry(e);

        if(e != null)
            m.deleteEntry(e);

        return result;
    }

    public function navigableKeySet():NavigableSet {
        var nksv:TreeMapKeySet = _navigableKeySetView;

        return (nksv != null) ? nksv : (_navigableKeySetView = new TreeMapKeySet(this));
    }

    override public function keySet():Set {
        return navigableKeySet();
    }

    public function descendingNavigableKeySet():NavigableSet {
        return descendingNavigableMap().navigableKeySet();
    }

    public function subMap(fromKey:*, toKey:*):SortedMap {
        return subNavigableMap(fromKey, true, toKey, false);
    }

    public function headMap(toKey:*):SortedMap {
        return headNavigableMap(toKey, false);
    }

    public function tailMap(fromKey:*):SortedMap {
        return tailNavigableMap(fromKey, true);
    }

    public function descendingNavigableMap():NavigableMap { throw new DefinitionError("abstract method"); }

    public function subNavigableMap(fromKey:*, fromInclusive:Boolean, toKey:*, toInclusive:Boolean):NavigableMap { throw new DefinitionError("abstract method"); }

    public function headNavigableMap(toKey:*, inclusive:Boolean):NavigableMap { throw new DefinitionError("abstract method"); }

    public function tailNavigableMap(fromKey:*, inclusive:Boolean):NavigableMap { throw new DefinitionError("abstract method"); }

    public function comparator():Comparator { throw new DefinitionError("abstract method"); }
}

}
