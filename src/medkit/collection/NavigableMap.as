/**
 * User: booster
 * Date: 9/9/12
 * Time: 12:23
 */

package medkit.collection {

public interface NavigableMap extends SortedMap {
    /**
     * Returns a key-value mapping associated with the greatest key
     * strictly less than the given key, or {@code null} if there is
     * no such key.
     *
     * @param key the key
     * @return an entry with the greatest key less than {@code key}, or {@code null} if there is no such key
     */
    function lowerEntry(key:*):MapEntry;

    /**
     * Returns the greatest key strictly less than the given key, or
     * {@code null} if there is no such key.
     *
     * @param key the key
     * @return the greatest key less than {@code key}, or {@code null} if there is no such key
     */
    function lowerKey(key:*):*;

    /**
     * Returns a key-value mapping associated with the greatest key
     * less than or equal to the given key, or {@code null} if there
     * is no such key.
     *
     * @param key the key
     * @return an entry with the greatest key less than or equal to {@code key}, or {@code null} if there is no such key
     */
    function floorEntry(key:*):MapEntry;

    /**
     * Returns the greatest key less than or equal to the given key,
     * or {@code null} if there is no such key.
     *
     * @param key the key
     * @return the greatest key less than or equal to {@code key}, or {@code null} if there is no such key
     */
    function floorKey(key:*):*;

    /**
     * Returns a key-value mapping associated with the least key
     * greater than or equal to the given key, or {@code null} if
     * there is no such key.
     *
     * @param key the key
     * @return an entry with the least key greater than or equal to {@code key}, or {@code null} if there is no such key
     */
    function ceilingEntry(key:*):MapEntry;

    /**
     * Returns the least key greater than or equal to the given key,
     * or {@code null} if there is no such key.
     *
     * @param key the key
     * @return the least key greater than or equal to {@code key}, or {@code null} if there is no such key
     */
    function ceilingKey(key:*):*;

    /**
     * Returns a key-value mapping associated with the least key
     * strictly greater than the given key, or {@code null} if there
     * is no such key.
     *
     * @param key the key
     * @return an entry with the least key greater than {@code key}, or {@code null} if there is no such key
     */
    function higherEntry(key:*):MapEntry;

    /**
     * Returns the least key strictly greater than the given key, or
     * {@code null} if there is no such key.
     *
     * @param key the key
     * @return the least key greater than {@code key}, or {@code null} if there is no such key
     */
    function higherKey(key:*):*;

    /**
     * Returns a key-value mapping associated with the least key in this map, or {@code null} if the map is empty.
     *
     * @return an entry with the least key, or {@code null} if this map is empty
     */
    function firstEntry():MapEntry;

    /**
     * Returns a key-value mapping associated with the greatest key in this map, or {@code null} if the map is empty.
     *
     * @return an entry with the greatest key, or {@code null} if this map is empty
     */
    function lastEntry():MapEntry;

    /**
     * Removes and returns a key-value mapping associated with the least key in this map, or {@code null} if the map is empty.
     *
     * @return the removed first entry of this map, or {@code null} if this map is empty
     */
    function pollFirstEntry():MapEntry;

    /**
     * Removes and returns a key-value mapping associated with the greatest key in this map, or {@code null} if the map is empty.
     *
     * @return the removed last entry of this map, or {@code null} if this map is empty
     */
    function pollLastEntry():MapEntry;

    /**
     * Returns a reverse order view of the mappings contained in this map.
     * The descending map is backed by this map, so changes to the map are
     * reflected in the descending map, and vice-versa.  If either map is
     * modified while an iteration over a collection view of either map
     * is in progress (except through the iterator's own {@code remove}
     * operation), the results of the iteration are undefined.
     *
     * @return a reverse order view of this map
     */
    function descendingNavigableMap():NavigableMap;

    /**
     * Returns a {@link NavigableSet} view of the keys contained in this map.
     * The set's iterator returns the keys in ascending order.
     * The set is backed by the map, so changes to the map are reflected in
     * the set, and vice-versa.  If the map is modified while an iteration
     * over the set is in progress (except through the iterator's own {@code
     * remove} operation), the results of the iteration are undefined.  The
     * set supports element removal, which removes the corresponding mapping
     * from the map, via the {@code Iterator.remove}, {@code Set.remove},
     * {@code removeAll}, {@code retainAll}, and {@code clear} operations.
     * It does not support the {@code add} or {@code addAll} operations.
     *
     * @return a navigable set view of the keys in this map
     */
    function navigableKeySet():NavigableSet;

    /**
     * Returns a reverse order {@link NavigableSet} view of the keys contained in this map.
     * The set's iterator returns the keys in descending order.
     * The set is backed by the map, so changes to the map are reflected in
     * the set, and vice-versa.  If the map is modified while an iteration
     * over the set is in progress (except through the iterator's own {@code
     * remove} operation), the results of the iteration are undefined.  The
     * set supports element removal, which removes the corresponding mapping
     * from the map, via the {@code Iterator.remove}, {@code Set.remove},
     * {@code removeAll}, {@code retainAll}, and {@code clear} operations.
     * It does not support the {@code add} or {@code addAll} operations.
     *
     * @return a reverse order navigable set view of the keys in this map
     */
    function descendingNavigableKeySet():NavigableSet;

    /**
     * Returns a view of the portion of this map whose keys range from
     * {@code fromKey} to {@code toKey}.  If {@code fromKey} and
     * {@code toKey} are equal, the returned map is empty unless
     * {@code fromExclusive} and {@code toExclusive} are both true.  The
     * returned map is backed by this map, so changes in the returned map are
     * reflected in this map, and vice-versa.  The returned map supports all
     * optional map operations that this map supports.
     *
     * @param fromKey low endpoint of the keys in the returned map
     * @param fromInclusive true if the low endpoint is to be included in the returned view
     * @param toKey high endpoint of the keys in the returned map
     * @param toInclusive true if the high endpoint is to be included in the returned view
     * @return a view of the portion of this map whose keys range from {@code fromKey} to {@code toKey}
     */
    function subNavigableMap(fromKey:*, fromInclusive:Boolean, toKey:*, toInclusive:Boolean):NavigableMap;

    /**
     * Returns a view of the portion of this map whose keys are less than (or
     * equal to, if {@code inclusive} is true) {@code toKey}.  The returned
     * map is backed by this map, so changes in the returned map are reflected
     * in this map, and vice-versa.  The returned map supports all optional
     * map operations that this map supports.
     *
     * @param toKey high endpoint of the keys in the returned map
     * @param inclusive true if the high endpoint is to be included in the returned view
     * @return a view of the portion of this map whose keys are less than (or equal to, if {@code inclusive} is true) {@code toKey}
     */
    function headNavigableMap(toKey:*, inclusive:Boolean):NavigableMap;

    /**
     * Returns a view of the portion of this map whose keys are greater than (or
     * equal to, if {@code inclusive} is true) {@code fromKey}.  The returned
     * map is backed by this map, so changes in the returned map are reflected
     * in this map, and vice-versa.  The returned map supports all optional
     * map operations that this map supports.
     *
     * @param fromKey low endpoint of the keys in the returned map
     * @param inclusive true if the low endpoint is to be included in the returned view
     * @return a view of the portion of this map whose keys are greater than (or equal to, if {@code inclusive} is true) {@code fromKey}
     */
    function tailNavigableMap(fromKey:*, inclusive:Boolean):NavigableMap;
}

}
