/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:18
 */

package medkit.collection {

import medkit.object.Comparator;
import medkit.object.Equalable;
import medkit.object.ObjectUtil;

public class ReverseComparator2 implements Comparator {
    internal var cmp:Comparator;

    public function ReverseComparator2(comparator:Comparator) {
        if(comparator == null)
            throw new ArgumentError("comparator must not be null");

        this.cmp = comparator;
    }

    public function compare(o1:*, o2:*):int {
        return cmp.compare(o2, o1);
    }

    public function equals(object:Equalable):Boolean {
        return (object === this) || (object is ReverseComparator2 && ObjectUtil.equals(cmp, object));
    }

    public function hashCode():int {
        return cmp.hashCode() ^ int.MIN_VALUE;
    }
}

}
