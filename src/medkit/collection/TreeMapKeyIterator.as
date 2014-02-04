/**
 * User: booster
 * Date: 12/16/12
 * Time: 12:12
 */

package medkit.collection {

public class TreeMapKeyIterator extends TreeMapPrivateEntryIterator{
    public function TreeMapKeyIterator(map:TreeMap, first:TreeMapEntry) {
        super(map, first);
    }

    override public function next():* {
        return nextEntry().key;
    }
}

}
