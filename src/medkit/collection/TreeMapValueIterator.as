/**
 * User: booster
 * Date: 12/16/12
 * Time: 12:11
 */

package medkit.collection {

public class TreeMapValueIterator extends TreeMapPrivateEntryIterator {
    public function TreeMapValueIterator(map:TreeMap, first:TreeMapEntry) {
        super(map, first);
    }

    override public function next():* {
        return nextEntry().value;
    }
}

}
