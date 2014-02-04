/**
 * User: booster
 * Date: 9/9/12
 * Time: 16:43
 */

package medkit.collection.error {

public class ConcurrentModificationError extends Error {
    public function ConcurrentModificationError(message:String = "", id:int = 0) {
        super(message, id);
    }
}

}
