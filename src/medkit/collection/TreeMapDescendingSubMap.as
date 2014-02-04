/**
 * User: booster
 * Date: 12/16/12
 * Time: 16:59
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.Comparator;

public class TreeMapDescendingSubMap extends TreeMapNavigableSubMap {
    private var _reverseComparator:Comparator;

    public function TreeMapDescendingSubMap(m:TreeMap, fromStart:Boolean, lo:*, loInclusive:Boolean, toEnd:Boolean, hi:*, hiInclusive:Boolean) {
        super(m, fromStart, lo, loInclusive, toEnd, hi, hiInclusive);

        _reverseComparator = Collections.reverseOrder(m.comparator());
    }

    override public function comparator():Comparator {
        return _reverseComparator;
    }

    override public function subNavigableMap(fromKey:*, fromInclusive:Boolean, toKey:*, toInclusive:Boolean):NavigableMap {
        if(!inRangeInclusive(fromKey, fromInclusive))
            throw new RangeError("fromKey out of range");

        if(!inRangeInclusive(toKey, toInclusive))
            throw new RangeError("toKey out of range");

        return new TreeMapDescendingSubMap(m,
            false, toKey, toInclusive,
            false, fromKey, fromInclusive
        );
    }

    override public function headNavigableMap(toKey:*, inclusive:Boolean):NavigableMap {
        if(!inRangeInclusive(toKey, inclusive))
            throw new RangeError("toKey out of range");

        return new TreeMapDescendingSubMap(m,
            false, toKey, inclusive,
            toEnd, hi, hiInclusive
        );
    }

    override public function tailNavigableMap(fromKey:*, inclusive:Boolean):NavigableMap {
        if(!inRangeInclusive(fromKey, inclusive))
            throw new RangeError("fromKey out of range");

        return new TreeMapDescendingSubMap(m,
            fromStart, lo, loInclusive,
            false, fromKey, inclusive
        );
    }

    override public function descendingNavigableMap():NavigableMap {
        var mv:NavigableMap  = _descendingMapView;

        return (mv != null) ? mv :
            (_descendingMapView =
             new TreeMapAscendingSubMap(m,
                 fromStart, lo, loInclusive,
                 toEnd, hi, hiInclusive));
    }

    override internal function keyIterator():Iterator {
        return new TreeMapNavigableSubMapDescendingKeyIterator(this, absHighest(), absLowFence());
    }

    override internal function descendingKeyIterator():Iterator {
        return new TreeMapNavigableSubMapKeyIterator(this, absLowest(), absHighFence());
    }

    override public function entrySet():Set {
        var es:TreeMapNavigableSubMapEntrySetView = _entrySetView;

        return (es != null) ? es : new TreeMapDescendingSubMapEntrySetView(this);
    }

    override internal function subLowest():TreeMapEntry { return absHighest(); }

    override internal function subHighest():TreeMapEntry { return absLowest(); }

    override internal function subCeiling(key:*):TreeMapEntry { return absFloor(key); }

    override internal function subHigher(key:*):TreeMapEntry { return absLower(key); }

    override internal function subFloor(key:*):TreeMapEntry { return absCeiling(key); }

    override internal function subLower(key:*):TreeMapEntry { return absHigher(key); }
}

}
