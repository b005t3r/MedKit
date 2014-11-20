/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:13
 */

package medkit.collection {

import medkit.collection.iterator.ListIterator;
import medkit.object.Comparable;
import medkit.object.Comparable;
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

    // TODO: change this to something faster
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

    /**
     * Searches the specified list for the specified object using the binary search algorithm.  The list must be sorted into ascending order
     * according to the {@linkplain Comparable natural ordering} of its elements (as by the {@link #sort(List)} method) prior to making this
     * call.  If it is not sorted, the results are undefined.  If the list contains multiple elements equal to the specified object, there is no
     * guarantee which one will be found.
     *
     * @param  list the list to be searched.
     * @param  key the key to be searched for.
     * @param  cmp Comparator to be used or null (in this case all elements have to implement Comparable)
     *
     * @return the index of the search key, if it is contained in the list; otherwise, <tt>(-(<i>insertion point</i>) - 1)</tt>.
     *         The <i>insertion point</i> is defined as the point at which the key would be inserted into the list: the index of the first
     *         element greater than the key, or <tt>list.size()</tt> if all elements in the list are less than the specified key.  Note
     *         that this guarantees that the return value will be &gt;= 0 if and only if the key is found.
     */
    public static function binarySearch(list:List, key:*, cmp:Comparator = null):int {
        var low:int = 0, high:int = list.size() - 1, mid:int;
        var midVal:*, result:int;

        if(cmp != null) {
            while(low <= high) {
                mid = (low + high) / 2;
                midVal = list.get(mid);

                result = cmp.compare(midVal, key);

                if(result < 0)      low = mid + 1;
                else if(result > 0) high = mid - 1;
                else                return mid; // key found
            }

            return -(low + 1);  // key not found
        }
        else {
            while(low <= high) {
                mid = (low + high) / 2;
                midVal = list.get(mid);

                result = Comparable(midVal).compareTo(Comparable(key));

                if(result < 0)      low = mid + 1;
                else if(result > 0) high = mid - 1;
                else                return mid; // key found
            }

            return -(low + 1);  // key not found
        }

    }
}
}
