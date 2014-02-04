/**
 * User: booster
 * Date: 9/8/12
 * Time: 12:29
 */

package medkit.collection {
import medkit.collection.iterator.Iterator;
import medkit.object.Cloneable;
import medkit.object.Equalable;
import medkit.object.Hashable;

/**
 * Basic Collection interface.
 * Based on Java-Collection-Framework.
 */
public interface Collection extends Equalable, Hashable, Cloneable {
    /**
     * Ensures that this collection contains the specified element (optional operation).
     *
     * @param o element to add
     * @returns true if this collection changed as a result of the call
     */
    function add(o:*):Boolean;

    /**
     * Ensures that this collection contains all elements of the specified collection (optional operation).
     *
     * @param c collection to add
     * @returns true if this collection changed as a result of the call
     */
    function addAll(c:Collection):Boolean;

    /**
     * Removes all of the elements from this collection (optional operation).
     */
    function clear():void;

    /**
     * Returns true if this list contains the specified element.
     *
     * @param o *
     * @returns true if this list contains the specified element.
     */
    function contains(o:*):Boolean;

    /**
     * Returns true if this collection contains all of the elements in the specified collection.
     *
     * @param c <code>Collection</code> collection to be checked for containment in this collection
     * @returns true if this collection contains all of the elements in the specified collection
     */
    function containsAll(c:Collection):Boolean;

    /**
     * Returns true if this list contains no elements.
     *
     * @returns true if this list contains no elements.
     */
    function isEmpty():Boolean;

    /**
     * Returns an iterator over the elements in this list.
     *
     * @returns Iterator
     */
    function iterator():Iterator;

    /**
     * Removes a single instance of the specified element from this collection, if it is present (optional operation).
     *
     * @param o object to be removed
     * @returns true if this collection changed as a result of the call
     */
    function remove(o:*):Boolean;

    /**
     * Removes all of this collection's elements that are also contained in the specified collection (optional operation).
     *
     * @param c <code>Collection</code> containing elements to be removed from this collection
     * @returns true if this collection changed as a result of the call
     */
    function removeAll(c:Collection):Boolean;

    /**
     * Retains only the elements in this collection that are contained in the
     * specified collection (optional operation).  In other words, removes from
     * this collection all of its elements that are not contained in the
     * specified collection.
     *
     * @param c collection containing elements to be retained in this collection
     * @returns true if this collection changed as a result of the call
     */
    function retainAll(c:Collection):Boolean;

    /**
     * Returns the number of elements in this collection.
     *
     * @returns number of elements in this collection
     */
    function size():int;

    /**
     * Converts this collection into an array.
     *
     * @returns an array
     */
    function toArray():Array;
}

}
