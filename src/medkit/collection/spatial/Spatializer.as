/**
 * User: booster
 * Date: 16/02/14
 * Time: 7:45
 */
package medkit.collection.spatial {

/** Calculates spatial indexes of other objects, for using them in spatial set. */
public interface Spatializer {
    /** Number of indexes used to index a given object. */
    function indexCount(obj:*):int

    /** Minimum value for a given index. */
    function minValue(obj:*, index:int):Number

    /** Maximum value for a given index. */
    function maxValue(obj:*, index:int):Number
}
}
