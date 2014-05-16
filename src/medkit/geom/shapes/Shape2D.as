/**
 * User: booster
 * Date: 14/05/14
 * Time: 11:11
 */
package medkit.geom.shapes {
import flash.geom.Matrix;

public interface Shape2D {
    function getBounds(result:Rectangle2D = null):Rectangle2D

    function intersectsRectangle2D(rect:Rectangle2D):Boolean

    function containsPoint2D(point:Point2D):Boolean
    function containsRectangle2D(rect:Rectangle2D):Boolean

    function getPathIterator(transformMatrix:Matrix = null, flatness:Number = 0):PathIterator
}
}
