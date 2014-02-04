/**
 * User: booster
 * Date: 11/17/12
 * Time: 17:45
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class HashMapValues extends AbstractCollection {
    private var map:HashMap;

    public function HashMapValues(map:HashMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return map.newValueIterator();
    }

    override public function clear():void {
        map.clear();
    }

    override public function contains(o:*):Boolean {
        return map.containsValue(o);
    }

    override public function size():int {
        return map._size;
    }
}

}
