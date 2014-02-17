/**
 * User: booster
 * Date: 15/02/14
 * Time: 10:44
 */
package medkit.collection.spatial {

/** Objects implementing this interface can be indexed by SpatialSet. */
public interface Spatial {
    /** How many spatial indexes are used for indexing this object. */
    function get indexCount():int

    /** Minimum value for a given index. */
    function minValue(index:int):Number

    /** Maximum value for a given index index. */
    function maxValue(index:int):Number
}
}
