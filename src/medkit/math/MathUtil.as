/**
 * User: booster
 * Date: 10/05/17
 * Time: 12:02
 */
package medkit.math {
public class MathUtil {
    public static function lerp(v0:Number, v1:Number, ratio:Number):Number {
        return (1.0 - ratio) * v0 + ratio * v1;
    }
}
}
