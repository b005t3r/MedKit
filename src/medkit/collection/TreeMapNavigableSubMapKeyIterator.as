/**
 * User: booster
 * Date: 12/16/12
 * Time: 16:09
 */

package medkit.collection {

public class TreeMapNavigableSubMapKeyIterator extends TreeMapNavigableSubMapIterator {
    public function TreeMapNavigableSubMapKeyIterator(map:TreeMapNavigableSubMap, first:TreeMapEntry, fence:TreeMapEntry) {
        super(map, first, fence);
    }

    override public function next():* {
        return nextEntry().key;
    }

    override public function remove():void {
        removeAscending();
    }
}

}
