/**
 * User: booster
 * Date: 9/9/12
 * Time: 10:55
 */

package medkit.collection {

import medkit.object.Comparator;

public interface SortedSet extends Set {
    /**
     * Returns the comparator used to order the elements in this set, or null if this set uses the natural
     * ordering of its elements.
     *
     * @returns comparator used to order the elements in this set, or null if this set uses the natural ordering
     */
    function comparator():Comparator;

    /**
     * Returns the first (lowest) element currently in this set.
     *
     * @returns first (lowest) element currently in this set
     */
    function first():*;

    /**
     * Returns the last (highest) element currently in this set.
     *
     * @returns last (highest) element currently in this set
     */
    function last():*;

    /**
     * Returns a view of the portion of this set whose elements are strictly less than toElement.
     * The returned set is backed by this set, so changes in the returned set are reflected in this set, and vice-versa.
     * The returned set supports all optional set operations that this set supports.
     *
     * @param toElement high endpoint (exclusive) of the returned set
     * @returns view of the portion of this set whose elements are strictly less than toElement
     */
    function headSet(toElement:*):SortedSet;

    /**
     * Returns a view of the portion of this set whose elements are greater than or equal to fromElement.
     * The returned set is backed by this set, so changes in the returned set are reflected in this set, and vice-versa.
     * The returned set supports all optional set operations that this set supports.
     *
     * @param fromElement low endpoint (inclusive) of the returned set
     * @returns view of the portion of this set whose elements are greater than or equal to fromElement
     */
    function tailSet(fromElement:*):SortedSet;

    /**
     * Returns a view of the portion of this set whose elements range from fromElement, inclusive, to toElement, exclusive.
     * (If fromElement and toElement are equal, the returned set is empty.) The returned set is backed by this set,
     * so changes in the returned set are reflected in this set, and vice-versa. The returned set supports all optional
     * set operations that this set supports.
     *
     * @param fromElement low endpoint (inclusive) of the returned set
     * @param toElement high endpoint (exclusive) of the returned set
     * @returns view of the portion of this set whose elements range from fromElement, inclusive, to toElement, exclusive.
     */
    function subSet(fromElement:*, toElement:*):SortedSet;
}

}
