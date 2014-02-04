/**
 * User: booster
 * Date: 9/8/12
 * Time: 11:50
 */

package medkit.object {

public interface Equalable {
    /**
     * Checks if two Equalable instances are equal.
     * @param object instance to check
     * @return true if equal, false otherwise
     */
    function equals(object:Equalable):Boolean;
}

}
