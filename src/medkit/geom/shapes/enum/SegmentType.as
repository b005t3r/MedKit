/**
 * User: booster
 * Date: 14/05/14
 * Time: 11:40
 */
package medkit.geom.shapes.enum {
import medkit.enum.Enum;

public class SegmentType extends Enum {
    { initEnums(SegmentType); }

    public static const MoveTo:SegmentType  = new SegmentType();
    public static const LineTo:SegmentType  = new SegmentType();
    public static const QuadTo:SegmentType  = new SegmentType();
    public static const CubicTo:SegmentType = new SegmentType();
    public static const Close:SegmentType   = new SegmentType();
}
}
