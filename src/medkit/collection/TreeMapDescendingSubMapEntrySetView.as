/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:08
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;

public class TreeMapDescendingSubMapEntrySetView extends TreeMapNavigableSubMapEntrySetView{
    function TreeMapDescendingSubMapEntrySetView(map:TreeMapNavigableSubMap) {
        super(map);
    }

    override public function iterator():Iterator {
        return new TreeMapNavigableSubMapDescendingEntryIterator(map, map.absHighest(), map.absLowFence());
    }
}

}
