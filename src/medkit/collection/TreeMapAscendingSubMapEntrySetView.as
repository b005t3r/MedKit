/**
 * User: booster
 * Date: 12/16/12
 * Time: 16:48
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class TreeMapAscendingSubMapEntrySetView extends TreeMapNavigableSubMapEntrySetView{
    function TreeMapAscendingSubMapEntrySetView(map:TreeMapNavigableSubMap) {
        super(map);
    }
    override public function iterator():Iterator {
        return new TreeMapNavigableSubMapEntryIterator(map, map.absLowest(), map.absHighFence());
    }
}

}
