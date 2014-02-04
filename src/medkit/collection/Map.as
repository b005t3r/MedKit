/**
 * User: booster
 * Date: 9/9/12
 * Time: 9:58
 */

package medkit.collection {

import medkit.object.Cloneable;
import medkit.object.Equalable;
import medkit.object.Hashable;

public interface Map extends Cloneable, Equalable, Hashable {
    /**
     * Returns true if this collection contains no elements.
     *
     * @returns true if this collection contains no elements.
     */
    function isEmpty():Boolean;

    /**
     * Returns the number of elements in this collection.
     *
     * @returns number of elements in this collection
     */
    function size():int;

    /**
     * Removes all of the elements from this collection (optional operation).
     */
    function clear():void;

    /**
     * Returns true if this map contains a mapping for the specified key.
     *
     * @param key whose presence in this map is to be tested
     * @returns true if this map contains a mapping for the specified key
     */
    function containsKey(key:*):Boolean;

    /**
     * Returns true if this map maps one or more keys to the specified value.
     *
     * @param value whose presence in this map is to be tested
     * @returns true if this map maps one or more keys to the specified value
     */
    function containsValue(value:*):Boolean;

    /**
     * Returns the value to which the specified key is mapped, or null if this map contains no mapping for the key.
     *
     * @param key whose associated value is to be returned
     * @returns value to which the specified key is mapped, or null if this map contains no mapping for the key
     */
    function get(key:*):*;

    /**
     * Returns a Set view of the keys contained in this map. The set is backed by the map, so changes to the map are
     * reflected in the set, and vice-versa.
     *
     * @returns set view of the keys contained in this map
     */
    function keySet():Set;

    /**
     * Returns a Set view of the mappings contained in this map. The set is backed by the map, so changes to the map are
     * reflected in the set, and vice-versa.
     *
     * @returns set view of the <code>MapEntry</code> objects contained in this map
     */
    function entrySet():Set;

    /**
     * Associates the specified value with the specified key in this map (optional operation).
     * If the map previously contained a mapping for the key, the old value is replaced by the specified value.
     *
     * @param key with which the specified value is to be associated
     * @param value to be associated with the specified key
     * @returns previous value associated with key, or null if there was no mapping for key
     */
    function put(key:*, value:*):*;

    /**
     * Removes the mapping for a key from this map if it is present (optional operation).
     * More formally, if this map contains a mapping from key, to value such that
     * <code>(key==null ?  k==null : key.equals(k))</code>, that mapping is removed.
     * (The map can contain at most one such mapping.)
     *
     * @param key key whose mapping is to be removed from the map
     * @return the previous value associated with <tt>key</tt>, or
     *         <tt>null</tt> if there was no mapping for <tt>key</tt>.
     */
    function removeKey(key:*):*;

    /**
     * Copies all of the mappings from the specified map to this map (optional operation).
     *
     * @param map containing mappings to be stored in this map
     * @returns previous value associated with key, or null if there was no mapping for key
     */
    function putAll(map:Map):void;

    /**
     * Returns a Collection view of the values contained in this map. The collection is backed by the map, so changes
     * to the map are reflected in the collection, and vice-versa.
     *
     * @returns collection view of the values contained in this map
     */
    function values():Collection;
}

}
