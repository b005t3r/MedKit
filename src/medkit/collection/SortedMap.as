/**
 * User: booster
 * Date: 9/9/12
 * Time: 11:32
 */

package medkit.collection {

import medkit.object.Comparator;

public interface SortedMap extends Map {
    /**
     * Returns the comparator used to order the keys in this map, or null if this map uses the natural
     * ordering of its keys.
     *
     * @returns comparator used to order the keys in this map, or null if this map uses the natural ordering
     */
    function comparator():Comparator;

    /**
     * Returns the first (lowest) key currently in this map.
     *
     * @returns first (lowest) key currently in this map
     */
    function firstKey():*;

    /**
     * Returns the last (highest) key currently in this map.
     *
     * @returns last (highest) key currently in this map
     */
    function lastKey():*;

    /**
     * Returns a view of the portion of this map whose keys are strictly less than toKey.
     * The returned map is backed by this map, so changes in the returned map are reflected in this map, and vice-versa.
     * The returned map supports all optional map operations that this map supports.
     *
     * @param toKey high endpoint (exclusive) of the returned map
     * @returns view of the portion of this map whose keys are strictly less than toKey
     */
    function headMap(toKey:*):SortedMap;

    /**
     * Returns a view of the portion of this map whose keys are greater than or equal to fromKey.
     * The returned map is backed by this map, so changes in the returned map are reflected in this map, and vice-versa.
     * The returned map supports all optional map operations that this map supports.
     *
     * @param fromKey low endpoint (inclusive) of the returned map
     * @returns view of the portion of this map whose keys are greater than or equal to fromKey
     */
    function tailMap(fromKey:*):SortedMap;

    /**
     * Returns a view of the portion of this map whose keys range from fromKey, inclusive, to toKey, exclusive.
     * (If fromKey and toKey are equal, the returned map is empty.) The returned map is backed by this map, so changes
     * in the returned map are reflected in this map, and vice-versa. The returned map supports all optional map
     * operations that this map supports.
     *
     * @param fromKey low endpoint (inclusive) of the returned map
     * @param toKey high endpoint (exclusive) of the returned map
     * @returns view of the portion of this map whose keys range from fromKey, inclusive, to toKey, exclusive
     */
    function subMap(fromKey:*, toKey:*):SortedMap;
}

}
