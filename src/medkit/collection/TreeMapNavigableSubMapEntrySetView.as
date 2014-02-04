/**
 * User: booster
 * Date: 12/16/12
 * Time: 15:24
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class TreeMapNavigableSubMapEntrySetView extends AbstractSet {
    protected var map:TreeMapNavigableSubMap;
    private var _size:int, sizeModCount:int;

    public function TreeMapNavigableSubMapEntrySetView(map:TreeMapNavigableSubMap) {
        this.map = map;

        _size = -1;
        sizeModCount = 0;
    }

    override public function size():int {
        if(map.fromStart && map.toEnd)
            return map.m.size();

        if(_size == -1 || sizeModCount != map.m.modCount) {
            sizeModCount = map.m.modCount;
            _size = 0;

            var i:Iterator = iterator();

            while(i.hasNext()) {
                _size++;
                i.next();
            }
        }
        return _size;
    }

    override public function isEmpty():Boolean {
        var n:TreeMapEntry = map.absLowest();
        return n == null || map.tooHigh(n.key);
    }

    override public function contains(o:*):Boolean {
        if(!(o is MapEntry))
            return false;

        var entry:MapEntry = o as MapEntry;
        var key:* = entry.getKey();

        if(!map.inRange(key))
            return false;

        var node:TreeMapEntry = map.m.getEntry(key);

        return node != null && TreeMap.valEquals(node.getValue(), entry.getValue());
    }

    override public function remove(o:*):Boolean {
        if(!(o is MapEntry))
            return false;

        var entry:MapEntry = o as MapEntry;
        var key:* = entry.getKey();

        if(!map.inRange(key))
            return false;

        var node:TreeMapEntry = map.m.getEntry(key);

        if(node != null && TreeMap.valEquals(node.getValue(), entry.getValue())) {
            map.m.deleteEntry(node);
            return true;
        }
        return false;
    }
}

}
