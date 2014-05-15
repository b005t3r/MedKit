/**
 * User: booster
 * Date: 9/8/12
 * Time: 13:52
 */

package medkit.collection.iterator {

public interface ListIterator extends Iterator {
    /**
     * Returns true if this list iterator has more elements when traversing the list in the reverse direction.
     *
     * @returns true if the list iterator has more elements when traversing the list in the reverse direction
     */
    function hasPrevious():Boolean;

    /**
     * Retrieves previous object in this list
     *
     * @returns previous object in this list
     */
    function previous():*;

    /**
     * Returns the index of the element that would be returned by a subsequent call to next(). (Returns list size if the list iterator is at the end of the list.)
     *
     * @returns index of the element that would be returned by a subsequent call to next(). (Returns list size if the list iterator is at the end of the list.)
     */
    function nextIndex():int;

    /**
     * Returns the index of the element that would be returned by a subsequent call to previous(). (Returns -1 if the list iterator is at the beginning of the list.)
     *
     * @returns index of the element that would be returned by a subsequent call to previous(). (Returns -1 if the list iterator is at the beginning of the list.)
     */
    function previousIndex():int;

    /**
     * Inserts the specified element into the list.
     * The element is inserted immediately before the next element that would
     * be returned by next, if any, and after the next element that would be
     * returned by previous, if any. (If the list contains no elements, the
     * new element becomes the sole element on the list.)
     *
     * @param o *
     */
    function add(o:*):void;

    /**
     * Replaces the last element returned by next or previous with the specified
     * element. This call can be made only if neither
     * ListIterator.remove nor ListIterator.add have been called after the
     * last call to next or previous.
     *
     * @param o *
     */
    function set(o:*):void;
}

}
