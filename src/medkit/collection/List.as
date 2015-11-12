/**
 * User: booster
 * Date: 9/8/12
 * Time: 13:34
 */

package medkit.collection {
import medkit.collection.iterator.ListIterator;

public interface List extends Collection {
    /**
     * Ensures that this list contains the specified element at the specified index (optional operation).
     *
     * @param o element to insert
     * @param index  index at which the specified element is to be inserted
     */
    function addAt(index:int, o:*):void;

    /**
     * Inserts all of the elements in the specified collection into this list at the specified position (optional operation).
     * Shifts the element currently at that position (if any) and any subsequent elements to the right (increases their indices).
     * The new elements will appear in this list in the order that they are returned by the specified collection's iterator.
     * The behavior of this operation is undefined if the specified collection is modified while the operation is in progress.
     * (Note that this will occur if the specified collection is this list, and it's nonempty.)
     *
     * @param c collection to insert
     * @param index at which to insert the first element from the specified collection
     * @returns true if this collection changed as a result of the call
     */
    function addAllAt(index:int, c:Collection):Boolean;

    /**
     * Returns the element at the specified position in this collection.
     *
     * @param index of the element to retrieve
     * @returns element at the specified index
     */
    function get(index:int):*;

    /**
     * Returns the index in this list of the first occurrence of the specified element, or -1 if this list
     * does not contain this element.
     *
     * @param o *
     * @return index
     */
    function indexOf(o:*):int;

    /**
     * Returns the index in this list of the last occurrence of the specified element, or -1 if this list
     * does not contain this element.
     *
     * @param o *
     * @return index
     */
    function lastIndexOf(o:*):int;

    /**
     * Returns the ListIterator of this List, starting from given index (default 0).
     *
     * @param index of teh first element in the iteration
     * @returns ListIterator of this List, starting from given index
     */
    function listIterator(index:int = 0):ListIterator;

    /**
     * Removes the element at the specified position in this list (optional operation).
     *
     * @param index of the element to be removed
     * @returns the removed element
     */
    function removeAt(index:int):*;

    /**
     * Replaces the element at the specified position in this list with the specified element (optional operation).
     *
     * @param index of the element to replace
     * @param o to be inserted
     * @returns element that was replaced
     */
    function set(index:int, o:*):*;

    /**
     * Returns a view of the portion of this list between the specified fromIndex, inclusive, and toIndex, exclusive.
     * (If toIndex >= fromIndex, the returned list is empty.)
     *
     * @param fromIndex low endpoint (including) of the subList
     * @param toIndex high endpoint (excluding) of the subList
     * @returns a view of the specified range within this list
     */
    function subList(fromIndex:int, toIndex:int):List;

    /**
     * Removes the portion of this list between the specified fromIndex, inclusive, and toIndex, exclusive.
     *
     * @param fromIndex first index to remove
     * @param toIndex first index not to be removed (toIndex-1 is the last one removed)
     */
    function removeRange(fromIndex:int, toIndex:int):void;
}
}
