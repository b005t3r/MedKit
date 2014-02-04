/**
 * User: booster
 * Date: 12/16/12
 * Time: 16:31
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Comparator;

public class TreeMapAscendingSubMap extends TreeMapNavigableSubMap {
    public function TreeMapAscendingSubMap(m:TreeMap, fromStart:Boolean, lo:*, loInclusive:Boolean, toEnd:Boolean, hi:*, hiInclusive:Boolean) {
        super(m, fromStart, lo, loInclusive, toEnd, hi, hiInclusive);
    }

    override public function comparator():Comparator {
        return m.comparator();
    }

    override public function subNavigableMap(fromKey:*, fromInclusive:Boolean, toKey:*, toInclusive:Boolean):NavigableMap {
        if(!inRangeInclusive(fromKey, fromInclusive))
            throw new RangeError("fromKey out of range");

        if(!inRangeInclusive(toKey, toInclusive))
            throw new RangeError("toKey out of range");

        return new TreeMapAscendingSubMap(m,
            false, fromKey, fromInclusive,
            false, toKey, toInclusive
        );
    }

    override public function headNavigableMap(toKey:*, inclusive:Boolean):NavigableMap {
        if(!inRangeInclusive(toKey, inclusive))
            throw new RangeError("toKey out of range");

        return new TreeMapAscendingSubMap(m,
            fromStart, lo, loInclusive,
            false, toKey, inclusive
        );
    }

    override public function tailNavigableMap(fromKey:*, inclusive:Boolean):NavigableMap {
        if(!inRangeInclusive(fromKey, inclusive))
            throw new RangeError("fromKey out of range");

        return new TreeMapAscendingSubMap(m,
            false, fromKey, inclusive,
            toEnd, hi, hiInclusive
        );
    }

    override public function descendingNavigableMap():NavigableMap {
        var mv:NavigableMap = _descendingMapView;

        return (mv != null) ? mv :
            (_descendingMapView =
             new TreeMapDescendingSubMap(m,
                 fromStart, lo, loInclusive,
                 toEnd, hi, hiInclusive));
    }

    override internal function keyIterator():Iterator {
        return new TreeMapNavigableSubMapKeyIterator(this, absLowest(), absHighFence());
    }

    override internal function descendingKeyIterator():Iterator {
        return new TreeMapNavigableSubMapDescendingKeyIterator(this, absHighest(), absLowFence());
    }

    override public function entrySet():Set {
        var es:TreeMapNavigableSubMapEntrySetView = _entrySetView;

        return (es != null) ? es : new TreeMapAscendingSubMapEntrySetView(this);
    }

    override internal function subLowest():TreeMapEntry { return absLowest(); }

    override internal function subHighest():TreeMapEntry { return absHighest(); }

    override internal function subCeiling(key:*):TreeMapEntry { return absCeiling(key); }

    override internal function subHigher(key:*):TreeMapEntry { return absHigher(key); }

    override internal function subFloor(key:*):TreeMapEntry { return absFloor(key); }

    override internal function subLower(key:*):TreeMapEntry { return absLower(key); }
}

}
