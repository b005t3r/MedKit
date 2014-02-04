/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:26
 */

package medkit.collection {

import medkit.object.Comparator;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

public class ReverseComparator implements Comparator {
    public function ReverseComparator() {
    }

    internal static const REVERSE_ORDER:ReverseComparator = new ReverseComparator();

    public function compare(o1:*, o2:*):int {
        return ObjectUtil.compare(o2, o1);
    }

    public function equals(object:Equalable):Boolean {
        return REVERSE_ORDER === this;
    }

    public function hashCode():int {
        return ObjectUtil.hashCode(REVERSE_ORDER);
    }
}

}
