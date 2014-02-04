/**
 * User: booster
 * Date: 2/17/13
 * Time: 12:35
 */

package medkit.object {
import medkit.enum.Enum;

public class CloningType extends Enum {
    // static constructor
    { initEnums(CloningType); }

    public static const NullClone:CloningType       = new CloningType();
    public static const ShallowClone:CloningType    = new CloningType();
    public static const DeepClone:CloningType       = new CloningType();
}

}
