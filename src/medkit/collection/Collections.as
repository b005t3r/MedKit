/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:13
 */

package medkit.collection {

import medkit.object.Comparator;

public class Collections {

    public static function reverseOrder(cmp:Comparator):Comparator {
        if(cmp == null)
            return ReverseComparator.REVERSE_ORDER;

        if(cmp is ReverseComparator2)
            return (cmp as ReverseComparator2).cmp;

        return new ReverseComparator2(cmp);
    }

}

}
