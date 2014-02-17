/**
 * User: booster
 * Date: 17/02/14
 * Time: 9:17
 */
package medkit.collection.spatial {
public class BucketDefinition {
    public var min:Number;
    public var max:Number;
    public var size:int;

    public function BucketDefinition(min:Number, max:Number, size:int) {
        this.min = min;
        this.max = max;
        this.size = size;
    }
}
}
