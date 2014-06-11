/**
 * User: booster
 * Date: 14/05/14
 * Time: 11:34
 */
package medkit.geom.shapes {
import medkit.geom.shapes.enum.SegmentType;
import medkit.geom.shapes.enum.WindingRule;

public interface PathIterator {
    function getWindingRule():WindingRule

    function isDone():Boolean
    function next():void;

    /**
     * Returns current segment type and its corresponding coords.
     * Different number of values is returned for different segment types:
     * - SegmentType.MoveTo, SegmentType.LineTo - one point
     * - SegmentType.QuadTo - two points
     * - SegmentType.CubicTo - three points
     * - SegmentType.Close - no points
     *
     * @param coords Vector containing 3 points to be used when passing segment coords
     * @return SegmentType for the current segment
     */
    function currentSegment(coords:Vector.<Point2D>):SegmentType
}
}
