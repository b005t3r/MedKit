/**
 * User: booster
 * Date: 12/16/12
 * Time: 11:42
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class TreeMapValues extends AbstractCollection {
    private var map:TreeMap;

    public function TreeMapValues(map:TreeMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return new TreeMapValueIterator(map,  map.getFirstEntry())
    }

    override public function size():int {
        return map.size();
    }

    override public function clear():void {
        map.clear();
    }

    override public function contains(o:*):Boolean {
        return map.containsValue(o);
    }

    override public function remove(o:*):Boolean {
        for (var e:TreeMapEntry = map.getFirstEntry(); e != null; e = TreeMap.successor(e)) {
            if (TreeMap.valEquals(e.getValue(), o)) {
                map.deleteEntry(e);
                return true;
            }
        }
        return false;
    }
}

}
