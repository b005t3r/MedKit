/**
 * User: booster
 * Date: 11/18/12
 * Time: 10:57
 */

package medkit.object.error {

public class CloneNotRegisteredError extends Error {
    public function CloneNotRegisteredError(message:String = "", id:int = 0) {
        super(message, id);
    }
}

}
