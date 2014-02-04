/**
 * User: booster
 * Date: 12/16/12
 * Time: 12:05
 */

package medkit.collection {

public class TreeMapEntryIterator extends TreeMapPrivateEntryIterator {
    public function TreeMapEntryIterator(map:TreeMap, first:TreeMapEntry) {
        super(map, first);
    }

    override public function next():* {
        return nextEntry();
    }
}

}
