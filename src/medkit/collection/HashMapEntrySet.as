/**
 * User: booster
 * Date: 11/17/12
 * Time: 17:51
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.object.ObjectUtil;

public class HashMapEntrySet extends AbstractSet {
    private var map:HashMap;

    public function HashMapEntrySet(map:HashMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return map.newEntryIterator();
    }

    override public function contains(o:*):Boolean {
        if (! (o is MapEntry))
            return false;

        var e:MapEntry          = o as MapEntry;
        var candidate:MapEntry  = map.getEntry(e.getKey());

        return candidate != null &&  ObjectUtil.equals(candidate, e);
    }

    override public function remove(o:*):Boolean {
        return map.removeMapping(o) != null;
    }

    override public function size():int {
        return map._size;
    }

    override public function clear():void {
        map.clear();
    }
}

}
