/**
 * User: booster
 * Date: 9/8/12
 * Time: 12:00
 */

package medkit.object {

public interface Comparable {
    /**
     * Compares two Comparable instances.
     *
     * @param object Comparable instance to compare
     * @returns a negative integer, zero, or a positive integer as this object is less than, equal to, or greater than the specified object
     */
    function compareTo(object:Comparable):int;
}

}
