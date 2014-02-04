/**
 * User: booster
 * Date: 11/14/12
 * Time: 17:58
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;

public class AbstractMapKeySet extends AbstractSet {
    private var map:AbstractMap;

    public function AbstractMapKeySet(map:AbstractMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return new AbstractMapKeySetIterator(map.keySet().iterator());
    }

    override public function size():int {
        return map.size();
    }

    override public function clear():void {
        map.clear();
    }

    override public function contains(o:*):Boolean {
        return map.containsKey(o);
    }

    override public function isEmpty():Boolean {
        return map.isEmpty();
    }
}

}
