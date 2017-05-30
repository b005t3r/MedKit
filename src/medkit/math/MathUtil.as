/**
 * User: booster
 * Date: 10/05/17
 * Time: 12:02
 */
package medkit.math {
public class MathUtil {
    public static function between(val:Number, min:Number, max:Number):Number {
        if(min > max)
            throw new ArgumentError("min must be greater or equal to max");

        return val < max
            ? val > min ? val : min
            : max
        ;
    }

    public static function lerp(v0:Number, v1:Number, ratio:Number):Number {
        return (1.0 - ratio) * v0 + ratio * v1;
    }
}
}
