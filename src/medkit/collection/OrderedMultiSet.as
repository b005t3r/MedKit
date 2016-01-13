/**
 * User: booster
 * Date: 13/01/16
 * Time: 13:46
 */
package medkit.collection {
public interface OrderedMultiSet extends OrderedSet, MultiSet {
    /**
     * Ensures this set contains at least as many copies of the given element.
     *
     * @param i element index
     * @param count number of copies to add
     * @return true if this collection changed as a result of the call
     */
    function addCountAt(i:int, count:int):Boolean

    /**
     * Removes the given number of copies of the specified element from this collection, if it is present (optional operation).
     *
     * @param i element index
     * @param count number of copies to remove
     * @return true if this collection changed as a result of the call
     */
    function removeCountAt(i:int, count:int):Boolean

    /**
     * Ensures this set contains exactly that many copies of the given element.
     *
     * @param i element index
     * @param count number of copies to set
     * @return true if this collection changed as a result of the call
     */
    function setCountAt(i:int, count:int):Boolean

    /**
     * Returns the number of copies of the the specified element (or zero if there are none present).
     *
     * @param i element index
     * @return number of copies of the specified element or zero if there are none present
     */
    function elementCountAt(i:int):int
}
}
