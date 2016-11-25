/**
 * User: booster
 * Date: 12/16/12
 * Time: 17:13
 */

package medkit.collection {

import medkit.collection.iterator.Iterator;
import medkit.collection.iterator.ListIterator;
import medkit.object.Comparable;
import medkit.object.Comparator;
import medkit.object.ObjectUtil;
import medkit.random.Random;
import medkit.random.Randomizer;

public class CollectionUtil {
    private static const SHUFFLE_THRESHOLD:int = 5;

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
            a.sort(function (objectA:*, objectB:*):Number {
                return ObjectUtil.compare(objectA, objectB);
            });
        }
        else {
            a.sort(function (objectA:*, objectB:*):Number {
                return cmp.compare(objectA, objectB);
            });
        }

        var i:ListIterator = list.listIterator();

        for(var j:int = 0; j < a.length; ++j) {
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

    /**
     * Returns <tt>true</tt> if the two specified collections have no
     * elements in common.
     *
     * <p>Care must be exercised if this method is used on collections that
     * do not comply with the general contract for <tt>Collection</tt>.
     * Implementations may elect to iterate over either collection and test
     * for containment in the other collection (or to perform any equivalent
     * computation).  If either collection uses a nonstandard equality test
     * (as does a {@link SortedSet} whose ordering is not <i>compatible with
     * equals</i>, or the key set of an {@link IdentityHashMap}), both
     * collections must use the same nonstandard equality test, or the
     * result of this method is undefined.
     *
     * <p>Note that it is permissible to pass the same collection in both
     * parameters, in which case the method will return true if and only if
     * the collection is empty.
     *
     * @param c1 a collection
     * @param c2 a collection
     * @throws NullPointerException if either collection is null
     * @since 1.5
     */
    public static function disjoint(c1:Collection, c2:Collection):Boolean {
        /*
         * We're going to iterate through c1 and test for inclusion in c2.
         * If c1 is a Set and c2 isn't, swap the collections.  Otherwise,
         * place the shorter collection in c1.  Hopefully this heuristic
         * will minimize the cost of the operation.
         */
        if((c1 is Set) && !(c2 is Set) || (c1.size() > c2.size())) {
            var tmp:Collection = c1;
            c1 = c2;
            c2 = tmp;
        }

        var iterator:Iterator = c1.iterator();
        while(iterator.hasNext()) {
            var e:* = iterator.next();

            if(c2.contains(e))
                return false;
        }

        return true;
    }

    /**
     * Randomly permute the specified list using the specified source of
     * randomness.  All permutations occur with equal likelihood
     * assuming that the source of randomness is fair.<p>
     *
     * This implementation traverses the list backwards, from the last element
     * up to the second, repeatedly swapping a randomly selected element into
     * the "current position".  Elements are randomly selected from the
     * portion of the list that runs from the first element to the current
     * position, inclusive.<p>
     *
     * This method runs in linear time.  If the specified list is not
     * the {@link ArrayList} instance and is large, this
     * implementation dumps the specified list into an array before shuffling
     * it, and dumps the shuffled array back into the list.  This avoids the
     * quadratic behavior that would result from shuffling a "sequential
     * access" list in place.
     *
     * @param  list the list to be shuffled.
     * @param  rnd the source of randomness to use to shuffle the list.
     * @throws UnsupportedOperationException if the specified list or its
     *         list-iterator does not support the <tt>set</tt> operation.
     */
    public static function shuffle(list:List, rnd:Randomizer = null):void {
        if(rnd == null)
            rnd = Random.fromDate();

        var i:int, size:int = list.size();
        if(size < SHUFFLE_THRESHOLD || list is ArrayList) {
            for(i = size; i > 1; --i)
                swap(list, i - 1, rnd.nextUnsignedInteger() % i);
        }
        else {
            var arr:Array = list.toArray();

            ArrayUtil.shuffle(arr, rnd);

            // Dump array back into list
            var it:ListIterator = list.listIterator();
            for(i = 0; i < size; ++i) {
                it.next();
                it.set(arr[i]);
            }
        }
    }

    public static function swap(l:List, i:int, j:int):void {
        l.set(i, l.set(j, l.get(i)));
    }

    public static function findObjectOfClass(clazz:Class, collection:Collection):* {
        if(collection is ArrayList) {
            var list:ArrayList = ArrayList(collection);

            var count:int = list.size();
            for(var i:int = 0; i < count; ++i) {
                var lo:* = list.get(i);

                if(lo is clazz == false)
                    continue;

                return lo;
            }
        }
        else {
            var it:Iterator = collection.iterator();
            while(it.hasNext()) {
                var co:* = it.next();

                if(co is clazz == false)
                    continue;

                return co;

            }
        }
    }

    public static function findAllObjectsOfClass(clazz:Class, collection:Collection, result:List = null):List {
        if(result == null) result = new ArrayList();

        if(collection is ArrayList) {
            var list:ArrayList = ArrayList(collection);

            var count:int = list.size();
            for(var i:int = 0; i < count; ++i) {
                var lo:* = list.get(i);

                if(lo is clazz == false)
                    continue;

                result.add(lo);
            }
        }
        else {
            var it:Iterator = collection.iterator();
            while(it.hasNext()) {
                var co:* = it.next();

                if(co is clazz == false)
                    continue;

                result.add(co);
            }
        }

        return result;
    }
}
}
