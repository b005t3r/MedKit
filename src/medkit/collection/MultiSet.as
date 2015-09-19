/**
 * User: booster
 * Date: 18/09/15
 * Time: 20:38
 */
package medkit.collection {
public interface MultiSet extends Set {
    /**
     * Ensures this set contains at least as many copies of the given element.
     *
     * @param o element to add
     * @param count number of copies to add
     * @return true if this collection changed as a result of the call
     */
    function addCount(o:*, count:int):Boolean

    /**
     * Removes the given number of copies of the specified element from this collection, if it is present (optional operation).
     *
     * @param o element to be removed
     * @param count number of copies to remove
     * @return true if this collection changed as a result of the call
     */
    function removeCount(o:*, count:int):Boolean

    /**
     * Ensures this set contains exactly that many copies of the given element.
     *
     * @param o element which count is to be set
     * @param count number of copies to set
     * @return true if this collection changed as a result of the call
     */
    function setCount(o:*, count:int):Boolean

    /**
     * Returns the number of copies of the the specified element (or zero if there are none present).
     *
     * @param o element which number of copiers is to be returned
     * @return number of copies of the specified element or zero if there are none present
     */
    function elementCount(o:*):int
}
}
