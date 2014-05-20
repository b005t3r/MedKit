/**
 * User: booster
 * Date: 19/05/14
 * Time: 9:34
 */
package medkit.object {

public interface Serializable {
    function readObject(input:ObjectInputStream):void
    function writeObject(output:ObjectOutputStream):void
}
}
