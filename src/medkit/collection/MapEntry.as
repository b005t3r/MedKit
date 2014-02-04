/**
 * User: booster
 * Date: 9/9/12
 * Time: 10:12
 */

package medkit.collection {

import medkit.object.Cloneable;
import medkit.object.Equalable;
import medkit.object.Hashable;

public interface MapEntry extends Equalable, Hashable, Cloneable {
    /**
     * Returns the key corresponding to this entry.
     *
     * @returns key corresponding to this entry
     */
    function getKey():*;

    /**
     * Returns the value corresponding to this entry. If the mapping has been removed from the backing map
     * (by the iterator's remove operation), the results of this call are undefined.
     *
     * @returns value corresponding to this entry
     */
    function getValue():*;

    /**
     * Replaces the value corresponding to this entry with the specified value (optional operation). (Writes through
     * to the map.) The behavior of this call is undefined if the mapping has already been removed from the map
     * (by the iterator's remove operation).
     *
     * @param value to be stored in this entry
     * @returns old value corresponding to the entry
     */
    function setValue(value:*):*;
}

}
