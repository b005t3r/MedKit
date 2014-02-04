/**
 * User: booster
 * Date: 11/17/12
 * Time: 11:18
 */

package medkit.collection {

internal class LinkedListEntry {
    internal var element:*;
    internal var next:LinkedListEntry;
    internal var previous:LinkedListEntry;

    public function LinkedListEntry(element:*, next:LinkedListEntry, previous:LinkedListEntry) {
        this.element = element;
        this.next = next;
        this.previous = previous;
    }
}

}
