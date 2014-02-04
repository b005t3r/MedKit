/**
 * User: booster
 * Date: 12/16/12
 * Time: 15:53
 */

package medkit.collection {

public class TreeMapNavigableSubMapEntryIterator extends TreeMapNavigableSubMapIterator {
    public function TreeMapNavigableSubMapEntryIterator(map:TreeMapNavigableSubMap, first:TreeMapEntry, fence:TreeMapEntry) {
        super(map, first, fence);
    }

    override public function next():* {
        return nextEntry();
    }

    override public function remove():void {
        removeAscending();
    }
}

}
