/**
 * User: booster
 * Date: 12/16/12
 * Time: 12:13
 */

package medkit.collection {

public class TreeMapDescendingKeyIterator extends TreeMapPrivateEntryIterator{
    public function TreeMapDescendingKeyIterator(map:TreeMap, first:TreeMapEntry) {
        super(map, first);
    }

    override public function next():* {
        return prevEntry().key;
    }
}

}
