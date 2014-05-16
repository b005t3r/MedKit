/**
 * User: booster
 * Date: 14/05/14
 * Time: 11:38
 */
package medkit.geom.shapes.enum {
import medkit.enum.Enum;

public class WindingRule extends Enum {
    { initEnums(WindingRule); }

    public static const EvenOdd:WindingRule = new WindingRule();
    public static const NonZero:WindingRule = new WindingRule();
}
}
