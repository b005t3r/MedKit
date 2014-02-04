/**
 * User: booster
 * Date: 9/8/12
 * Time: 12:53
 */

package medkit.collection.iterator {
/**
 * Generic interface for traversing data-structures.
 */
public interface Iterator {
    /**
     * Returns true if the iteration has more elements.
     *
     * @returns true if the iteration has more elements
     */
    function hasNext():Boolean;

    /**
     * Returns the next element in the iteration.
     *
     * @returns next object in the iteration
     * @throws NoSuchElementException if there is no more elements in this iteration
     */
    function next():*;

    /**
     * Removes the last element from the underlying collection returned by the iterator.
     */
    function remove():void;
}

}
