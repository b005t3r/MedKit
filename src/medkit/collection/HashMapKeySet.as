/**
 * User: booster
 * Date: 11/17/12
 * Time: 17:41
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class HashMapKeySet extends AbstractSet {
    internal var map:HashMap;

    public function HashMapKeySet(map:HashMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return map.newKeyIterator();
    }

    override public function size():int {
        return map._size;
    }

    override public function contains(o:*):Boolean {
        return map.containsKey(o);
    }

    override public function remove(o:*):Boolean {
        return map.removeEntryForKey(o) != null;
    }

    override public function clear():void {
        map.clear();
    }
}

}
