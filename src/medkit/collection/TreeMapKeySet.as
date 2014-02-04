/**
 * User: booster
 * Date: 12/16/12
 * Time: 12:30
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Comparator;

public class TreeMapKeySet extends AbstractSet implements NavigableSet {
    private var m:NavigableMap;

    public function TreeMapKeySet(map:NavigableMap) { m = map; }

    override public function iterator():Iterator {
        if(m is TreeMap)
            return (m as TreeMap).keyIterator();
        else if(m is TreeMapNavigableSubMap)
            return (m as TreeMapNavigableSubMap).keyIterator();
        else
            throw new ArgumentError("this TreeMapKeySet must be created using TreeMap or TreeMapNavigableSubMap instance");
    }

    public function descendingIterator():Iterator {
        if(m is TreeMap)
            return (m as TreeMap).descendingKeyIterator();
        else if(m is TreeMapNavigableSubMap)
            return (m as TreeMapNavigableSubMap).descendingKeyIterator();
        else
            throw new ArgumentError("this TreeMapKeySet must be created using TreeMap or TreeMapNavigableSubMap instance");
    }

    override public function size():int { return m.size(); }

    override public function isEmpty():Boolean { return m.isEmpty(); }

    override public function contains(o:*):Boolean { return m.containsKey(o); }

    override public function clear():void { m.clear(); }

    public function lower(e:*):* { return m.lowerKey(e); }

    public function floor(e:*):* { return m.floorKey(e); }

    public function ceiling(e:*):* { return m.ceilingKey(e); }

    public function higher(e:*):* { return m.higherKey(e); }

    public function first():* { return m.firstKey(); }

    public function last():* { return m.lastKey(); }

    public function comparator():Comparator { return m.comparator(); }

    public function pollFirst():* {
        var e:MapEntry = m.pollFirstEntry();

        return e == null ? null : e.getKey();
    }

    public function pollLast():* {
        var e:MapEntry = m.pollLastEntry();
        return e == null ? null : e.getKey();
    }

    override public function remove(o:*):Boolean {
        var oldSize:int = size();
        m.removeKey(o);
        return size() != oldSize;
    }

    public function subNavigableSet(fromElement:*, fromInclusive:Boolean, toElement:*, toInclusive:Boolean):NavigableSet {
        return new TreeMapKeySet(m.subNavigableMap(fromElement, fromInclusive, toElement, toInclusive));
    }

    public function headNavigableSet(toElement:*, inclusive:Boolean):NavigableSet {
        return new TreeMapKeySet(m.headNavigableMap(toElement, inclusive));
    }

    public function tailNavigableSet(fromElement:*, inclusive:Boolean):NavigableSet {
        return new TreeMapKeySet(m.tailNavigableMap(fromElement, inclusive));
    }

    public function subSet(fromElement:*, toElement:*):SortedSet {
        return subNavigableSet(fromElement, true, toElement, false);
    }

    public function headSet(toElement:*):SortedSet {
        return headNavigableSet(toElement, false);
    }

    public function tailSet(fromElement:*):SortedSet {
        return tailNavigableSet(fromElement, true);
    }

    public function descendingNavigableSet():NavigableSet {
        return new TreeMapKeySet(m.descendingNavigableMap());
    }
}

}
