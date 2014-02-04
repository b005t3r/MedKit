/**
 * User: booster
 * Date: 12/16/12
 * Time: 16:10
 */

package medkit.collection {

public class TreeMapNavigableSubMapDescendingEntryIterator extends TreeMapNavigableSubMapIterator {
    public function TreeMapNavigableSubMapDescendingEntryIterator(map:TreeMapNavigableSubMap, first:TreeMapEntry, fence:TreeMapEntry) {
        super(map, first, fence);
    }

    override public function next():* {
        return prevEntry();
    }

    override public function remove():void {
        removeDescending();
    }
}

}
