/**
 * User: booster
 * Date: 12/16/12
 * Time: 11:49
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class TreeMapEntrySet extends AbstractSet {
    private var map:TreeMap;

    public function TreeMapEntrySet(map:TreeMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return new TreeMapEntryIterator(map,  map.getFirstEntry());
    }

    override public function size():int {
        return map.size();
    }

    override public function clear():void {
        map.clear();
    }

    override public function contains(o:*):Boolean {
        if (! (o is MapEntry))
            return false;

        var entry:MapEntry  = o as MapEntry;
        var value:*         = entry.getValue();
        var p:TreeMapEntry  = map.getEntry(entry.getKey());

        return p != null && TreeMap.valEquals(p.getValue(), value);
    }

    override public function remove(o:*):Boolean {
        if (! (o is MapEntry))
            return false;

        var entry:MapEntry  = o as MapEntry;
        var value:*         = entry.getValue();
        var p:TreeMapEntry  = map.getEntry(entry.getKey());

        if (p != null && TreeMap.valEquals(p.getValue(), value)) {
            map.deleteEntry(p);
            return true;
        }

        return false;
    }
}

}
