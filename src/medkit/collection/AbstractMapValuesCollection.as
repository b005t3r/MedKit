/**
 * User: booster
 * Date: 11/14/12
 * Time: 18:07
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;

public class AbstractMapValuesCollection extends AbstractCollection {
    private var map:AbstractMap;

    public function AbstractMapValuesCollection(map:AbstractMap) {
        this.map = map;
    }

    override public function iterator():Iterator {
        return new AbstractMapValuesCollectionIterator(map.values().iterator());
    }

    override public function size():int {
        return map.size();
    }

    override public function isEmpty():Boolean {
        return map.isEmpty();
    }

    override public function clear():void {
        map.clear();
    }

    override public function contains(o:*):Boolean {
        return map.containsValue(o);
    }
}

}
