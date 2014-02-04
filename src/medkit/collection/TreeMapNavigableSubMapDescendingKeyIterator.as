/**
 * User: booster
 * Date: 12/16/12
 * Time: 16:13
 */

package medkit.collection {

public class TreeMapNavigableSubMapDescendingKeyIterator extends TreeMapNavigableSubMapIterator {
    public function TreeMapNavigableSubMapDescendingKeyIterator(map:TreeMapNavigableSubMap, first:TreeMapEntry, fence:TreeMapEntry) {
        super(map, first, fence);
    }

    override public function next():* {
        return prevEntry().key;
    }

    override public function remove():void {
        removeDescending();
    }
}

}
