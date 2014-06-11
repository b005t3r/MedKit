/**
 * User: booster
 * Date: 11/06/14
 * Time: 12:28
 */
package medkit.geom.shapes {
import flash.geom.Matrix;

import medkit.collection.spatial.Spatial;
import medkit.object.Equalable;
import medkit.object.Hashable;

public class Line2D implements Spatial, Shape2D, Equalable, Hashable {
    /**
     * Returns an indicator of where the specified point {@code (px,py)} lies with respect to the line segment from
     * {@code (x1,y1)} to {@code (x2,y2)}. The return value can be either 1, -1, or 0 and indicates
     * in which direction the specified line must pivot around its first end point, {@code (x1,y1)}, in order to point at the
     * specified point {@code (px,py)}. <p>A return value of 1 indicates that the line segment must
     * turn in the direction that takes the positive X axis towards the negative Y axis.  In the default coordinate system used by
     * Java 2D, this direction is counterclockwise. <p>A return value of -1 indicates that the line segment must
     * turn in the direction that takes the positive X axis towards the positive Y axis.  In the default coordinate system, this
     * direction is clockwise.
     * <p>A return value of 0 indicates that the point lies exactly on the line segment.  Note that an indicator value
     * of 0 is rare and not useful for determining colinearity because of floating point rounding issues.
     * <p>If the point is colinear with the line segment, but not between the end points, then the value will be -1 if the point
     * lies "beyond {@code (x1,y1)}" or 1 if the point lies "beyond {@code (x2,y2)}".
     *
     * @param x1 the X coordinate of the start point of the specified line segment
     * @param y1 the Y coordinate of the start point of the specified line segment
     * @param x2 the X coordinate of the end point of the specified line segment
     * @param y2 the Y coordinate of the end point of the specified line segment
     * @param px the X coordinate of the specified point to be compared with the specified line segment
     * @param py the Y coordinate of the specified point to be compared with the specified line segment
     * @return an integer that indicates the position of the third specified coordinates with respect to the line
     * segment formed by the first two specified coordinates.
     */
    public static function relativeCCW(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number):int {
        x2 -= x1;
        y2 -= y1;
        px -= x1;
        py -= y1;

        var ccw:Number = px * y2 - py * x2;

        if(ccw == 0.0) {
            // The point is colinear, classify based on which side of
            // the segment the point falls on.  We can calculate a
            // relative value using the projection of px,py onto the
            // segment - a negative value indicates the point projects
            // outside of the segment in the direction of the particular
            // endpoint used as the origin for the projection.
            ccw = px * x2 + py * y2;

            if(ccw > 0.0) {
                // Reverse the projection to be relative to the original x2,y2
                // x2 and y2 are simply negated.
                // px and py need to have (x2 - x1) or (y2 - y1) subtracted
                //    from them (based on the original values)
                // Since we really want to get a positive answer when the
                //    point is "beyond (x2,y2)", then we want to calculate
                //    the inverse anyway - thus we leave x2 & y2 negated.
                px -= x2;
                py -= y2;
                ccw = px * x2 + py * y2;

                if(ccw < 0.0) {
                    ccw = 0.0;
                }
            }
        }

        return (ccw < 0.0) ? -1 : ((ccw > 0.0) ? 1 : 0);
    }

    /**
     * Tests if the line segment from {@code (x1,y1)} to {@code (x2,y2)} intersects the line segment from {@code (x3,y3)}
     * to {@code (x4,y4)}.
     *
     * @param x1 the X coordinate of the start point of the first specified line segment
     * @param y1 the Y coordinate of the start point of the first specified line segment
     * @param x2 the X coordinate of the end point of the first specified line segment
     * @param y2 the Y coordinate of the end point of the first specified line segment
     * @param x3 the X coordinate of the start point of the second specified line segment
     * @param y3 the Y coordinate of the start point of the second specified line segment
     * @param x4 the X coordinate of the end point of the second specified line segment
     * @param y4 the Y coordinate of the end point of the second specified line segment
     * @return <code>true</code> if the first specified line segment and the second specified line segment intersect
     * each other; <code>false</code> otherwise.
     */
    public static function intersectsLine(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Boolean {
        return ((relativeCCW(x1, y1, x2, y2, x3, y3) * relativeCCW(x1, y1, x2, y2, x4, y4) <= 0)
            && (relativeCCW(x3, y3, x4, y4, x1, y1) * relativeCCW(x3, y3, x4, y4, x2, y2) <= 0))
            ;
    }

    /**
     * Returns the square of the distance from a point to a line segment.
     * The distance measured is the distance between the specified point and the closest point between the specified end points.
     * If the specified point intersects the line segment in between the end points, this method returns 0.0.
     *
     * @param x1 the X coordinate of the start point of the specified line segment
     * @param y1 the Y coordinate of the start point of the specified line segment
     * @param x2 the X coordinate of the end point of the specified line segment
     * @param y2 the Y coordinate of the end point of the specified line segment
     * @param px the X coordinate of the specified point being measured against the specified line segment
     * @param py the Y coordinate of the specified point being measured against the specified line segment
     * @return a double value that is the square of the distance from the specified point to the specified line segment.
     */
    public static function pointSegmentDistanceSq(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number):Number {
        // Adjust vectors relative to x1,y1
        // x2,y2 becomes relative vector from x1,y1 to end of segment
        x2 -= x1;
        y2 -= y1;

        // px,py becomes relative vector from x1,y1 to test point
        px -= x1;
        py -= y1;

        var dotprod:Number = px * x2 + py * y2;
        var projlenSq:Number;

        if(dotprod <= 0.0) {
            // px,py is on the side of x1,y1 away from x2,y2
            // distance to segment is length of px,py vector
            // "length of its (clipped) projection" is now 0.0
            projlenSq = 0.0;
        }
        else {
            // switch to backwards vectors relative to x2,y2
            // x2,y2 are already the negative of x1,y1=>x2,y2
            // to get px,py to be the negative of px,py=>x2,y2
            // the dot product of two negated vectors is the same
            // as the dot product of the two normal vectors
            px = x2 - px;
            py = y2 - py;

            dotprod = px * x2 + py * y2;

            if(dotprod <= 0.0) {
                // px,py is on the side of x2,y2 away from x1,y1
                // distance to segment is length of (backwards) px,py vector
                // "length of its (clipped) projection" is now 0.0
                projlenSq = 0.0;
            }
            else {
                // px,py is between x1,y1 and x2,y2
                // dotprod is the length of the px,py vector
                // projected on the x2,y2=>x1,y1 vector times the
                // length of the x2,y2=>x1,y1 vector
                projlenSq = dotprod * dotprod / (x2 * x2 + y2 * y2);
            }
        }

        // Distance to line is now the length of the relative point
        // vector minus the length of its projection onto the line
        // (which is zero if the projection falls outside the range
        //  of the line segment).
        var lenSq:Number = px * px + py * py - projlenSq;

        if(lenSq < 0)
            lenSq = 0;

        return lenSq;
    }

    /**
     * Returns the distance from a point to a line segment.
     * The distance measured is the distance between the specified point and the closest point between the specified end points.
     * If the specified point intersects the line segment in between the end points, this method returns 0.0.
     *
     * @param x1 the X coordinate of the start point of the specified line segment
     * @param y1 the Y coordinate of the start point of the specified line segment
     * @param x2 the X coordinate of the end point of the specified line segment
     * @param y2 the Y coordinate of the end point of the specified line segment
     * @param px the X coordinate of the specified point being measured against the specified line segment
     * @param py the Y coordinate of the specified point being measured against the specified line segment
     * @return a double value that is the distance from the specified point to the specified line segment.
     */
    public static function pointSegmentDistance(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number):Number {
        return Math.sqrt(pointSegmentDistanceSq(x1, y1, x2, y2, px, py));
    }

    /**
     * Returns the square of the distance from a point to a line.
     * The distance measured is the distance between the specified point and the closest point on the infinitely-extended line
     * defined by the specified coordinates.  If the specified point intersects the line, this method returns 0.0.
     *
     * @param x1 the X coordinate of the start point of the specified line
     * @param y1 the Y coordinate of the start point of the specified line
     * @param x2 the X coordinate of the end point of the specified line
     * @param y2 the Y coordinate of the end point of the specified line
     * @param px the X coordinate of the specified point being measured against the specified line
     * @param py the Y coordinate of the specified point being measured against the specified line
     * @return a double value that is the square of the distance from the specified point to the specified line.
     */
    public static function pointLineDistanceSq(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number):Number {
        // Adjust vectors relative to x1,y1
        // x2,y2 becomes relative vector from x1,y1 to end of segment
        x2 -= x1;
        y2 -= y1;

        // px,py becomes relative vector from x1,y1 to test point
        px -= x1;
        py -= y1;

        var dotprod:Number = px * x2 + py * y2;

        // dotprod is the length of the px,py vector
        // projected on the x1,y1=>x2,y2 vector times the
        // length of the x1,y1=>x2,y2 vector
        var projlenSq:Number = dotprod * dotprod / (x2 * x2 + y2 * y2);

        // Distance to line is now the length of the relative point
        // vector minus the length of its projection onto the line
        var lenSq:Number = px * px + py * py - projlenSq;

        if(lenSq < 0)
            lenSq = 0;

        return lenSq;
    }

    /**
     * Returns the distance from a point to a line.
     * The distance measured is the distance between the specified point and the closest point on the infinitely-extended line
     * defined by the specified coordinates.  If the specified point intersects the line, this method returns 0.0.
     *
     * @param x1 the X coordinate of the start point of the specified line
     * @param y1 the Y coordinate of the start point of the specified line
     * @param x2 the X coordinate of the end point of the specified line
     * @param y2 the Y coordinate of the end point of the specified line
     * @param px the X coordinate of the specified point being measured against the specified line
     * @param py the Y coordinate of the specified point being measured against the specified line
     * @return a double value that is the distance from the specified point to the specified line.
     */
    public static function pointLineDistance(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number):Number {
        return Math.sqrt(pointLineDistanceSq(x1, y1, x2, y2, px, py));
    }

    public var x1:Number;
    public var y1:Number;
    public var x2:Number;
    public var y2:Number;

    public function Line2D(x1:Number, y1:Number, x2:Number, y2:Number) {
        setTo(x1, y1, x2, y2);
    }

    public function setTo(x1:Number, y1:Number, x2:Number, y2:Number):void {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
    }

    public function get indexCount():int { return 2; }

    public function minValue(index:int):Number { return index == 0 ? (x1 < x2 ? x1 : x2) : (y1 < y2 ? y1 : y2); }

    public function maxValue(index:int):Number { return index == 0 ? (x1 > x2 ? x1 : x2) : (y1 > y2 ? y1 : y2); }

    public function getBounds(result:Rectangle2D = null):Rectangle2D {
        if(result == null) result = new Rectangle2D();

        var x:Number, y:Number, w:Number, h:Number;
        if(x1 < x2) {
            x = x1;
            w = x2 - x1;
        }
        else {
            x = x2;
            w = x1 - x2;
        }
        if(y1 < y2) {
            y = y1;
            h = y2 - y1;
        }
        else {
            y = y2;
            h = y1 - y2;
        }

        result.setTo(x, y, w, h);

        return result;
    }

    public function intersectsRectangle2D(rect:Rectangle2D):Boolean {
        return rect.intersectsLine2D(this);
    }

    public function containsPoint2D(point:Point2D):Boolean {
        return false; // line has no area
    }

    public function containsRectangle2D(rect:Rectangle2D):Boolean {
        return false; // line has no area
    }

    public function getPathIterator(transformMatrix:Matrix = null, flatness:Number = 0):PathIterator {
        return new LineIterator(this, transformMatrix);
    }

    public function equals(object:Equalable):Boolean {
        var line:Line2D = object as Line2D;

        if(line == null)
            return false;

        return (line.x1 == x1 && line.x2 == x2 && line.y1 == y1 && line.y2 == y2)
            || (line.x2 == x1 && line.x1 == x2 && line.y2 == y1 && line.y1 == y2)
            ;
    }

    public function hashCode():int {
        return (y2 << 24) | (x2 << 16) | (y1 << 8) | x1;
    }

    public function relativeCCW(px:Number, py:Number):int {
        return Line2D.relativeCCW(x1, y1, x2, y2, px, py);
    }

    public function intersectsLine(x1:Number, y1:Number, x2:Number, y2:Number):Boolean {
        return Line2D.intersectsLine(x1, y1, x2, y2, this.x1, this.y1, this.x2, this.y2);
    }

    public function intersectsLine2D(l:Line2D):Boolean {
        return Line2D.intersectsLine(l.x1, l.y1, l.x2, l.y2, x1, y1, x2, y2);
    }

    public function pointSegmentDistanceSq(px:Number, py:Number):Number {
        return Line2D.pointSegmentDistanceSq(x1, y1, x2, y2, px, py);
    }

    public function point2DSegmentDistanceSq(pt:Point2D):Number {
        return Line2D.pointSegmentDistanceSq(x1, y1, x2, y2, pt.x, pt.y);
    }

    public function pointSegmentDistance(px:Number, py:Number):Number {
        return Line2D.pointSegmentDistance(x1, y1, x2, y2, px, py);
    }

    public function point2DSegmentDistance(pt:Point2D):Number {
        return Line2D.pointSegmentDistance(x1, y1, x2, y2, pt.x, pt.y);
    }

    public function pointLineDistanceSq(px:Number, py:Number):Number {
        return Line2D.pointLineDistanceSq(x1, y1, x2, y2, px, py);
    }

    public function point2DLineDistanceSq(pt:Point2D):Number {
        return Line2D.pointLineDistanceSq(x1, y1, x2, y2, pt.x, pt.y);
    }

    public function pointLineDistance(px:Number, py:Number):Number {
        return Line2D.pointLineDistance(x1, y1, x2, y2, px, py);
    }

    public function point2DLineDistance(pt:Point2D):Number {
        return Line2D.pointLineDistance(x1, y1, x2, y2, pt.x, pt.y);
    }
}
}

import flash.geom.Matrix;

import medkit.geom.GeomUtil;

import medkit.geom.shapes.Line2D;

import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.enum.SegmentType;
import medkit.geom.shapes.enum.WindingRule;

class LineIterator implements PathIterator {
    public var line:Line2D;
    public var matrix:Matrix;
    public var index:int;

    public function LineIterator(line:Line2D, matrix:Matrix = null) {
        this.line   = line;
        this.matrix = matrix;
        this.index  = 0;
    }

    public function getWindingRule():WindingRule { return WindingRule.NonZero; }

    public function isDone():Boolean {
        return index > 1;
    }

    public function next():void { ++index; }

    public function currentSegment(coords:Vector.<Point2D>):SegmentType {
        if (index > 2)
            throw new RangeError("rect iterator out of bounds");

        if(index == 0) {
            coords[0].x = line.x1;
            coords[0].y = line.y1;
        }
        else {
            coords[0].x = line.x2;
            coords[0].y = line.y2;
        }

        if (matrix != null)
            GeomUtil.transformPoint2D(matrix, coords[0].x, coords[0].y, coords[0]);

        return index == 0 ? SegmentType.MoveTo : SegmentType.LineTo;
    }
}
