/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:13
 */

package medkit.collection {

import medkit.collection.iterator.ListIterator;
import medkit.object.Comparator;
import medkit.object.ObjectUtil;

public class CollectionUtil {

    public static function reverseOrder(cmp:Comparator):Comparator {
        if(cmp == null)
            return ReverseComparator.REVERSE_ORDER;

        if(cmp is ReverseComparator2)
            return (cmp as ReverseComparator2).cmp;

        return new ReverseComparator2(cmp);
    }

    public static function sort(list:List, cmp:Comparator = null):void {
        var a:Array = list.toArray();

        if(cmp == null) {
            a.sort(function(objectA:*, objectB:*):Number {
                return ObjectUtil.compare(objectA, objectB);
            });
        }
        else {
            a.sort(function(objectA:*, objectB:*):Number {
                return cmp.compare(objectA, objectB);
            });
        }

        var i:ListIterator = list.listIterator();

        for (var j:int = 0; j < a.length; ++j) {
            i.next();
            i.set(a[j]);
        }
    }
}
}
