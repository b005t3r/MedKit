/**
 * User: booster
 * Date: 9/9/12
 * Time: 11:02
 */

package medkit.object {

public interface Comparator extends Equalable, Hashable {
    /**
     * Compares its two arguments for order. Returns a negative integer, zero, or a positive integer as the first
     * argument is less than, equal to, or greater than the second.
     *
     * @param o1 the first object to be compared
     * @param o2 the second object to be compared
     * @returns a negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second
     */
    function compare(o1:*, o2:*):int;
}

}
