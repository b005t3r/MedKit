/**
 * User: booster
 * Date: 14/05/14
 * Time: 16:07
 */
package medkit.geom.shapes.curve {
import medkit.geom.*;
import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.crossings.Crossings;
import medkit.geom.shapes.enum.SegmentType;

public class Curve {
    public static const INCREASING:int  = 1;
    public static const DECREASING:int = -1;

    protected var direction:int;

    public static function insertMove(curves:Vector.<Curve>, x:Number, y:Number):void {
        curves[curves.length] = new Order0(x, y);
    }

    public static function insertLine(curves:Vector.<Curve>, x0:Number, y0:Number, x1:Number, y1:Number):void {
        if (y0 < y1) {
            curves[curves.length] = new Order1(x0, y0, x1, y1, INCREASING);
        } else if (y0 > y1) {
            curves[curves.length] = new Order1(x1, y1, x0, y0, DECREASING);
        } else {
            // Do not add horizontal lines
        }
    }

    public static function insertQuad(curves:Vector.<Curve>, x0:Number, y0:Number, coords:Vector.<Point2D>):void {
        var y1:Number = coords[1].y;

        if(y0 > y1) {
            Order2.insert(curves, coords, coords[1].x, y1, coords[0].x, coords[0].y, x0, y0, DECREASING);
        }
        else if(y0 == y1 && y0 == coords[0].y) {
            // Do not add horizontal lines
            return;
        }
        else {
            Order2.insert(curves, coords, x0, y0, coords[0].x, coords[0].y, coords[1].x, y1, INCREASING);
        }
    }

    public static function insertCubic(curves:Vector.<Curve>, x0:Number, y0:Number, coords:Vector.<Point2D>):void {
        var y1:Number = coords[2].y;

        if(y0 > y1) {
            Order3.insert(curves, coords, coords[2].x, y1, coords[1].x, coords[1].y, coords[0].x, coords[0].y, x0, y0, DECREASING);
        }
        else if(y0 == y1 && y0 == coords[0].y && y0 == coords[1].y) {
            // Do not add horizontal lines
            return;
        }
        else {
            Order3.insert(curves, coords, x0, y0, coords[0].x, coords[0].y, coords[1].x, coords[1].y, coords[2].x, y1, INCREASING);
        }
    }

    /**
     * Calculates the number of times the given path
     * crosses the ray extending to the right from (px,py).
     * If the point lies on a part of the path,
     * then no crossings are counted for that intersection.
     * +1 is added for each crossing where the Y coordinate is increasing
     * -1 is added for each crossing where the Y coordinate is decreasing
     * The return value is the sum of all crossings for every segment in
     * the path.
     * The path must start with a SEG_MOVETO, otherwise an exception is
     * thrown.
     * The caller must check p[xy] for NaN values.
     * The caller may also reject infinite p[xy] values as well.
     */
    public static function pointCrossingsForPath(pi:PathIterator, px:Number, py:Number):int {
        if(pi.isDone()) {
            return 0;
        }
        var coords:Vector.<Point2D> = new Vector.<Point2D>(3, true);
        coords[0] = new Point2D();
        coords[1] = new Point2D();
        coords[2] = new Point2D();

        if(pi.currentSegment(coords) != SegmentType.MoveTo)
            throw new ArgumentError("missing initial moveto in path definition");

        pi.next();

        var movx:Number = coords[0].x;
        var movy:Number = coords[0].y;
        var curx:Number = movx;
        var cury:Number = movy;
        var endx:Number, endy:Number;

        var crossings:int = 0;

        while(!pi.isDone()) {
            switch(pi.currentSegment(coords)) {
                case SegmentType.MoveTo:
                    if(cury != movy)
                        crossings += pointCrossingsForLine(px, py, curx, cury, movx, movy);

                    movx = curx = coords[0].x;
                    movy = cury = coords[0].y;
                    break;

                case SegmentType.LineTo:
                    endx = coords[0].x;
                    endy = coords[0].y;
                    crossings += pointCrossingsForLine(px, py, curx, cury, endx, endy);
                    curx = endx;
                    cury = endy;
                    break;

                case SegmentType.QuadTo:
                    endx = coords[1].x;
                    endy = coords[1].y;
                    crossings += pointCrossingsForQuad(px, py, curx, cury, coords[0].x, coords[0].y, endx, endy, 0);
                    curx = endx;
                    cury = endy;
                    break;

                case SegmentType.CubicTo:
                    endx = coords[2].x;
                    endy = coords[2].y;
                    crossings += pointCrossingsForCubic(px, py, curx, cury, coords[0].x, coords[0].y, coords[1].x, coords[1].y, endx, endy, 0);
                    curx = endx;
                    cury = endy;
                    break;

                case SegmentType.Close:
                    if(cury != movy)
                        crossings += pointCrossingsForLine(px, py, curx, cury, movx, movy);

                    curx = movx;
                    cury = movy;
                    break;
            }

            pi.next();
        }

        if(cury != movy)
            crossings += pointCrossingsForLine(px, py, curx, cury, movx, movy);

        return crossings;
    }

    /**
     * Calculates the number of times the line from (x0,y0) to (x1,y1)
     * crosses the ray extending to the right from (px,py).
     * If the point lies on the line, then no crossings are recorded.
     * +1 is returned for a crossing where the Y coordinate is increasing
     * -1 is returned for a crossing where the Y coordinate is decreasing
     */
    public static function pointCrossingsForLine(px:Number, py:Number, x0:Number, y0:Number, x1:Number, y1:Number):int {
        if(py < y0 && py < y1) return 0;
        if(py >= y0 && py >= y1) return 0;
        // assert(y0 != y1);
        if(px >= x0 && px >= x1) return 0;
        if(px < x0 && px < x1) return (y0 < y1) ? 1 : -1;

        var xintercept:Number = x0 + (py - y0) * (x1 - x0) / (y1 - y0);

        if(px >= xintercept) return 0;

        return (y0 < y1) ? 1 : -1;
    }

    /**
     * Calculates the number of times the quad from (x0,y0) to (x1,y1)
     * crosses the ray extending to the right from (px,py).
     * If the point lies on a part of the curve,
     * then no crossings are counted for that intersection.
     * the level parameter should be 0 at the top-level call and will count
     * up for each recursion level to prevent infinite recursion
     * +1 is added for each crossing where the Y coordinate is increasing
     * -1 is added for each crossing where the Y coordinate is decreasing
     */
    public static function pointCrossingsForQuad(px:Number, py:Number, x0:Number, y0:Number, xc:Number, yc:Number, x1:Number, y1:Number, level:int):int {
        if(py < y0 && py < yc && py < y1) return 0;
        if(py >= y0 && py >= yc && py >= y1) return 0;
        // Note y0 could equal y1...
        if(px >= x0 && px >= xc && px >= x1) return 0;
        if(px < x0 && px < xc && px < x1) {
            if(py >= y0) {
                if(py < y1) return 1;
            }
            else {
                // py < y0
                if(py >= y1) return -1;
            }
            // py outside of y01 range, and/or y0==y1
            return 0;
        }

        // double precision only has 52 bits of mantissa
        if(level > 52) return pointCrossingsForLine(px, py, x0, y0, x1, y1);

        var x0c:Number = (x0 + xc) / 2;
        var y0c:Number = (y0 + yc) / 2;
        var xc1:Number = (xc + x1) / 2;
        var yc1:Number = (yc + y1) / 2;
        xc = (x0c + xc1) / 2;
        yc = (y0c + yc1) / 2;

        // xc != xc - fast isNaN test
        if(xc != xc || yc != yc) {
            // [xy]c are NaN if any of [xy]0c or [xy]c1 are NaN
            // [xy]0c or [xy]c1 are NaN if any of [xy][0c1] are NaN
            // These values are also NaN if opposing infinities are added
            return 0;
        }

        return pointCrossingsForQuad(px, py, x0, y0, x0c, y0c, xc, yc, level + 1)
            + pointCrossingsForQuad(px, py, xc, yc, xc1, yc1, x1, y1, level + 1)
            ;
    }

    /**
     * Calculates the number of times the cubic from (x0,y0) to (x1,y1)
     * crosses the ray extending to the right from (px,py).
     * If the point lies on a part of the curve,
     * then no crossings are counted for that intersection.
     * the level parameter should be 0 at the top-level call and will count
     * up for each recursion level to prevent infinite recursion
     * +1 is added for each crossing where the Y coordinate is increasing
     * -1 is added for each crossing where the Y coordinate is decreasing
     */
    public static function pointCrossingsForCubic(px:Number, py:Number, x0:Number, y0:Number, xc0:Number, yc0:Number, xc1:Number, yc1:Number, x1:Number, y1:Number, level:int):int {
        if(py < y0 && py < yc0 && py < yc1 && py < y1) return 0;
        if(py >= y0 && py >= yc0 && py >= yc1 && py >= y1) return 0;
        // Note y0 could equal yc0...
        if(px >= x0 && px >= xc0 && px >= xc1 && px >= x1) return 0;
        if(px < x0 && px < xc0 && px < xc1 && px < x1) {
            if(py >= y0) {
                if(py < y1) return 1;
            }
            else {
                // py < y0
                if(py >= y1) return -1;
            }
            // py outside of y01 range, and/or y0==yc0
            return 0;
        }

        // double precision only has 52 bits of mantissa
        if(level > 52) return pointCrossingsForLine(px, py, x0, y0, x1, y1);

        var xmid:Number = (xc0 + xc1) / 2;
        var ymid:Number = (yc0 + yc1) / 2;
        xc0 = (x0 + xc0) / 2;
        yc0 = (y0 + yc0) / 2;
        xc1 = (xc1 + x1) / 2;
        yc1 = (yc1 + y1) / 2;
        var xc0m:Number = (xc0 + xmid) / 2;
        var yc0m:Number = (yc0 + ymid) / 2;
        var xmc1:Number = (xmid + xc1) / 2;
        var ymc1:Number = (ymid + yc1) / 2;
        xmid = (xc0m + xmc1) / 2;
        ymid = (yc0m + ymc1) / 2;

        if(xmid != xmid || ymid != ymid) {
            // [xy]mid are NaN if any of [xy]c0m or [xy]mc1 are NaN
            // [xy]c0m or [xy]mc1 are NaN if any of [xy][c][01] are NaN
            // These values are also NaN if opposing infinities are added
            return 0;
        }

        return pointCrossingsForCubic(px, py, x0, y0, xc0, yc0, xc0m, yc0m, xmid, ymid, level + 1)
            + pointCrossingsForCubic(px, py, xmid, ymid, xmc1, ymc1, xc1, yc1, x1, y1, level + 1)
        ;
    }

    /**
     * The rectangle intersection test counts the number of times
     * that the path crosses through the shadow that the rectangle
     * projects to the right towards (x => +INFINITY).
     *
     * During processing of the path it actually counts every time
     * the path crosses either or both of the top and bottom edges
     * of that shadow.  If the path enters from the top, the count
     * is incremented.  If it then exits back through the top, the
     * same way it came in, the count is decremented and there is
     * no impact on the winding count.  If, instead, the path exits
     * out the bottom, then the count is incremented again and a
     * full pass through the shadow is indicated by the winding count
     * having been incremented by 2.
     *
     * Thus, the winding count that it accumulates is actually double
     * the real winding count.  Since the path is continuous, the
     * final answer should be a multiple of 2, otherwise there is a
     * logic error somewhere.
     *
     * If the path ever has a direct hit on the rectangle, then a
     * special value is returned.  This special value terminates
     * all ongoing accumulation on up through the call chain and
     * ends up getting returned to the calling function which can
     * then produce an answer directly.  For intersection tests,
     * the answer is always "true" if the path intersects the
     * rectangle.  For containment tests, the answer is always
     * "false" if the path intersects the rectangle.  Thus, no
     * further processing is ever needed if an intersection occurs.
     */
    public static const RECT_INTERSECTS:int = 0x7FFFFFFF;

    /**
     * Accumulate the number of times the path crosses the shadow
     * extending to the right of the rectangle.  See the comment
     * for the RECT_INTERSECTS constant for more complete details.
     * The return value is the sum of all crossings for both the
     * top and bottom of the shadow for every segment in the path,
     * or the special value RECT_INTERSECTS if the path ever enters
     * the interior of the rectangle.
     * The path must start with a SEG_MOVETO, otherwise an exception is
     * thrown.
     * The caller must check r[xy]{min,max} for NaN values.
     */
    public static function rectCrossingsForPath(pi:PathIterator, rxmin:Number, rymin:Number, rxmax:Number, rymax:Number):int {
        if(rxmax <= rxmin || rymax <= rymin)
            return 0;

        if(pi.isDone())
            return 0;

        var coords:Vector.<Point2D> = new Vector.<Point2D>(3, true);
        coords[0] = new Point2D();
        coords[1] = new Point2D();
        coords[2] = new Point2D();

        if(pi.currentSegment(coords) != SegmentType.MoveTo)
            throw new ArgumentError("missing initial moveto in path definition");

        pi.next();

        var curx:Number, cury:Number, movx:Number, movy:Number, endx:Number, endy:Number;
        curx = movx = coords[0].x;
        cury = movy = coords[0].y;

        var crossings:int = 0;
        while(crossings != RECT_INTERSECTS && !pi.isDone()) {
            switch(pi.currentSegment(coords)) {
                case SegmentType.MoveTo:
                    if(curx != movx || cury != movy)
                        crossings = rectCrossingsForLine(crossings, rxmin, rymin, rxmax, rymax, curx, cury, movx, movy);

                    // Count should always be a multiple of 2 here.
                    // assert((crossings & 1) != 0);
                    movx = curx = coords[0].x;
                    movy = cury = coords[0].y;
                    break;

                case SegmentType.LineTo:
                    endx = coords[0].x;
                    endy = coords[0].y;
                    crossings = rectCrossingsForLine(crossings, rxmin, rymin, rxmax, rymax, curx, cury, endx, endy);
                    curx = endx;
                    cury = endy;
                    break;

                case SegmentType.QuadTo:
                    endx = coords[1].x;
                    endy = coords[1].y;
                    crossings = rectCrossingsForQuad(crossings, rxmin, rymin, rxmax, rymax, curx, cury, coords[0].x, coords[0].y, endx, endy, 0);
                    curx = endx;
                    cury = endy;
                    break;

                case SegmentType.CubicTo:
                    endx = coords[2].x;
                    endy = coords[2].y;
                    crossings = rectCrossingsForCubic(crossings, rxmin, rymin, rxmax, rymax, curx, cury, coords[0].x, coords[0].y, coords[1].x, coords[1].y, endx, endy, 0);
                    curx = endx;
                    cury = endy;
                    break;

                case SegmentType.Close:
                    if(curx != movx || cury != movy)
                        crossings = rectCrossingsForLine(crossings, rxmin, rymin, rxmax, rymax, curx, cury, movx, movy);

                    curx = movx;
                    cury = movy;
                    // Count should always be a multiple of 2 here.
                    // assert((crossings & 1) != 0);
                    break;
            }

            pi.next();
        }

        if(crossings != RECT_INTERSECTS && (curx != movx || cury != movy))
            crossings = rectCrossingsForLine(crossings, rxmin, rymin, rxmax, rymax, curx, cury, movx, movy);

        // Count should always be a multiple of 2 here.
        // assert((crossings & 1) != 0);
        return crossings;
    }

    /**
     * Accumulate the number of times the line crosses the shadow
     * extending to the right of the rectangle.  See the comment
     * for the RECT_INTERSECTS constant for more complete details.
     */
    public static function rectCrossingsForLine(crossings:int, rxmin:Number, rymin:Number, rxmax:Number, rymax:Number, x0:Number, y0:Number, x1:Number, y1:Number):int {
        if(y0 >= rymax && y1 >= rymax) return crossings;
        if(y0 <= rymin && y1 <= rymin) return crossings;
        if(x0 <= rxmin && x1 <= rxmin) return crossings;
        if(x0 >= rxmax && x1 >= rxmax) {
            // Line is entirely to the right of the rect
            // and the vertical ranges of the two overlap by a non-empty amount
            // Thus, this line segment is partially in the "right-shadow"
            // Path may have done a complete crossing
            // Or path may have entered or exited the right-shadow
            if(y0 < y1) {
                // y-increasing line segment...
                // We know that y0 < rymax and y1 > rymin
                if(y0 <= rymin) crossings++;
                if(y1 >= rymax) crossings++;
            }
            else if(y1 < y0) {
                // y-decreasing line segment...
                // We know that y1 < rymax and y0 > rymin
                if(y1 <= rymin) crossings--;
                if(y0 >= rymax) crossings--;
            }

            return crossings;
        }

        // Remaining case:
        // Both x and y ranges overlap by a non-empty amount
        // First do trivial INTERSECTS rejection of the cases
        // where one of the endpoints is inside the rectangle.
        if((x0 > rxmin && x0 < rxmax && y0 > rymin && y0 < rymax) ||
           (x1 > rxmin && x1 < rxmax && y1 > rymin && y1 < rymax)) {
            return RECT_INTERSECTS;
        }

        // Otherwise calculate the y intercepts and see where
        // they fall with respect to the rectangle
        var xi0:Number = x0;

        if(y0 < rymin)
            xi0 += ((rymin - y0) * (x1 - x0) / (y1 - y0));
        else if(y0 > rymax)
            xi0 += ((rymax - y0) * (x1 - x0) / (y1 - y0));

        var xi1:Number = x1;
        if(y1 < rymin)
            xi1 += ((rymin - y1) * (x0 - x1) / (y0 - y1));
        else if(y1 > rymax)
            xi1 += ((rymax - y1) * (x0 - x1) / (y0 - y1));

        if(xi0 <= rxmin && xi1 <= rxmin) return crossings;

        if(xi0 >= rxmax && xi1 >= rxmax) {
            if(y0 < y1) {
                // y-increasing line segment...
                // We know that y0 < rymax and y1 > rymin
                if(y0 <= rymin) crossings++;
                if(y1 >= rymax) crossings++;
            }
            else if(y1 < y0) {
                // y-decreasing line segment...
                // We know that y1 < rymax and y0 > rymin
                if(y1 <= rymin) crossings--;
                if(y0 >= rymax) crossings--;
            }

            return crossings;
        }

        return RECT_INTERSECTS;
    }

    /**
     * Accumulate the number of times the quad crosses the shadow
     * extending to the right of the rectangle.  See the comment
     * for the RECT_INTERSECTS constant for more complete details.
     */
    public static function rectCrossingsForQuad(crossings:int, rxmin:Number, rymin:Number, rxmax:Number, rymax:Number, x0:Number, y0:Number, xc:Number, yc:Number, x1:Number, y1:Number, level:int):int {
        if(y0 >= rymax && yc >= rymax && y1 >= rymax) return crossings;
        if(y0 <= rymin && yc <= rymin && y1 <= rymin) return crossings;
        if(x0 <= rxmin && xc <= rxmin && x1 <= rxmin) return crossings;
        if(x0 >= rxmax && xc >= rxmax && x1 >= rxmax) {
            // Quad is entirely to the right of the rect
            // and the vertical range of the 3 Y coordinates of the quad
            // overlaps the vertical range of the rect by a non-empty amount
            // We now judge the crossings solely based on the line segment
            // connecting the endpoints of the quad.
            // Note that we may have 0, 1, or 2 crossings as the control
            // point may be causing the Y range intersection while the
            // two endpoints are entirely above or below.
            if(y0 < y1) {
                // y-increasing line segment...
                if(y0 <= rymin && y1 > rymin) crossings++;
                if(y0 < rymax && y1 >= rymax) crossings++;
            }
            else if(y1 < y0) {
                // y-decreasing line segment...
                if(y1 <= rymin && y0 > rymin) crossings--;
                if(y1 < rymax && y0 >= rymax) crossings--;
            }

            return crossings;
        }

        // The intersection of ranges is more complicated
        // First do trivial INTERSECTS rejection of the cases
        // where one of the endpoints is inside the rectangle.
        if((x0 < rxmax && x0 > rxmin && y0 < rymax && y0 > rymin) ||
           (x1 < rxmax && x1 > rxmin && y1 < rymax && y1 > rymin)) {
            return RECT_INTERSECTS;
        }

        // Otherwise, subdivide and look for one of the cases above.
        // double precision only has 52 bits of mantissa
        if(level > 52) {
            return rectCrossingsForLine(crossings,
                rxmin, rymin, rxmax, rymax,
                x0, y0, x1, y1);
        }

        var x0c:Number = (x0 + xc) / 2;
        var y0c:Number = (y0 + yc) / 2;
        var xc1:Number = (xc + x1) / 2;
        var yc1:Number = (yc + y1) / 2;
        xc = (x0c + xc1) / 2;
        yc = (y0c + yc1) / 2;

        // xc != xc - fast isNaN test
        if(xc != xc || yc != yc) {
            // [xy]c are NaN if any of [xy]0c or [xy]c1 are NaN
            // [xy]0c or [xy]c1 are NaN if any of [xy][0c1] are NaN
            // These values are also NaN if opposing infinities are added
            return 0;
        }

        crossings = rectCrossingsForQuad(crossings, rxmin, rymin, rxmax, rymax, x0, y0, x0c, y0c, xc, yc, level + 1);

        if(crossings != RECT_INTERSECTS)
            crossings = rectCrossingsForQuad(crossings, rxmin, rymin, rxmax, rymax, xc, yc, xc1, yc1, x1, y1, level + 1);


        return crossings;
    }

    /**
     * Accumulate the number of times the cubic crosses the shadow
     * extending to the right of the rectangle.  See the comment
     * for the RECT_INTERSECTS constant for more complete details.
     */
    public static function rectCrossingsForCubic(crossings:int, rxmin:Number, rymin:Number, rxmax:Number, rymax:Number, x0:Number, y0:Number, xc0:Number, yc0:Number, xc1:Number, yc1:Number, x1:Number, y1:Number, level:int):int {
        if(y0 >= rymax && yc0 >= rymax && yc1 >= rymax && y1 >= rymax) {
            return crossings;
        }
        if(y0 <= rymin && yc0 <= rymin && yc1 <= rymin && y1 <= rymin) {
            return crossings;
        }
        if(x0 <= rxmin && xc0 <= rxmin && xc1 <= rxmin && x1 <= rxmin) {
            return crossings;
        }
        if(x0 >= rxmax && xc0 >= rxmax && xc1 >= rxmax && x1 >= rxmax) {
            // Cubic is entirely to the right of the rect
            // and the vertical range of the 4 Y coordinates of the cubic
            // overlaps the vertical range of the rect by a non-empty amount
            // We now judge the crossings solely based on the line segment
            // connecting the endpoints of the cubic.
            // Note that we may have 0, 1, or 2 crossings as the control
            // points may be causing the Y range intersection while the
            // two endpoints are entirely above or below.
            if(y0 < y1) {
                // y-increasing line segment...
                if(y0 <= rymin && y1 > rymin) crossings++;
                if(y0 < rymax && y1 >= rymax) crossings++;
            }
            else if(y1 < y0) {
                // y-decreasing line segment...
                if(y1 <= rymin && y0 > rymin) crossings--;
                if(y1 < rymax && y0 >= rymax) crossings--;
            }
            return crossings;
        }
        // The intersection of ranges is more complicated
        // First do trivial INTERSECTS rejection of the cases
        // where one of the endpoints is inside the rectangle.
        if((x0 > rxmin && x0 < rxmax && y0 > rymin && y0 < rymax) ||
           (x1 > rxmin && x1 < rxmax && y1 > rymin && y1 < rymax)) {
            return RECT_INTERSECTS;
        }
        // Otherwise, subdivide and look for one of the cases above.
        // double precision only has 52 bits of mantissa
        if(level > 52)
            return rectCrossingsForLine(crossings, rxmin, rymin, rxmax, rymax, x0, y0, x1, y1);

        var xmid:Number = (xc0 + xc1) / 2;
        var ymid:Number = (yc0 + yc1) / 2;
        xc0 = (x0 + xc0) / 2;
        yc0 = (y0 + yc0) / 2;
        xc1 = (xc1 + x1) / 2;
        yc1 = (yc1 + y1) / 2;
        var xc0m:Number = (xc0 + xmid) / 2;
        var yc0m:Number = (yc0 + ymid) / 2;
        var xmc1:Number = (xmid + xc1) / 2;
        var ymc1:Number = (ymid + yc1) / 2;
        xmid = (xc0m + xmc1) / 2;
        ymid = (yc0m + ymc1) / 2;

        // xmid != xmid - fast isNaN test
        if(xmid != xmid || ymid != ymid) {
            // [xy]mid are NaN if any of [xy]c0m or [xy]mc1 are NaN
            // [xy]c0m or [xy]mc1 are NaN if any of [xy][c][01] are NaN
            // These values are also NaN if opposing infinities are added
            return 0;
        }

        crossings = rectCrossingsForCubic(crossings, rxmin, rymin, rxmax, rymax, x0, y0, xc0, yc0, xc0m, yc0m, xmid, ymid, level + 1);

        if(crossings != RECT_INTERSECTS) {
            crossings = rectCrossingsForCubic(crossings,
                rxmin, rymin, rxmax, rymax,
                xmid, ymid, xmc1, ymc1,
                xc1, yc1, x1, y1, level + 1);
        }
        return crossings;
    }

    public function Curve(direction:int) {
        this.direction = direction;
    }

    public final function getDirection():int {
        return direction;
    }

    public final function getWithDirection(direction:int):Curve {
        return (this.direction == direction ? this : getReversedCurve());
    }

    public static function round(v:Number):Number {
        //return Math.rint(v*10)/10;
        return v;
    }

    public static function orderof(x1:Number, x2:Number):int {
        if(x1 < x2) {
            return -1;
        }
        if(x1 > x2) {
            return 1;
        }
        return 0;
    }

    public static function signeddiffbits(y1:Number, y2:Number):Number {
        //return (Double.doubleToLongBits(y1) - Double.doubleToLongBits(y2));
        throw new Error("unimplemented");
    }

    public static function diffbits(y1:Number, y2:Number):Number {
        //return Math.abs(Double.doubleToLongBits(y1) - Double.doubleToLongBits(y2));
        throw new Error("unimplemented");
    }

    public static function prev(v:Number):Number {
        //return Double.longBitsToDouble(Double.doubleToLongBits(v)-1);
        throw new Error("unimplemented");
    }

    public static function next(v:Number):Number {
        //return Double.longBitsToDouble(Double.doubleToLongBits(v)+1);
        throw new Error("unimplemented");
    }

    public function toString():String {
        return ("Curve[" +
                getOrder() + ", " +
                ("(" + round(getX0()) + ", " + round(getY0()) + "), ") +
                controlPointString() +
                ("(" + round(getX1()) + ", " + round(getY1()) + "), ") +
                (direction == INCREASING ? "D" : "U") +
                "]");
    }

    public function controlPointString():String{
        return "";
    }

    public function getOrder():int { throw new Error("abstract method;") }
    public function getXTop():Number { throw new Error("abstract method;") }
    public function getYTop():Number { throw new Error("abstract method;") }
    public function getXBot():Number { throw new Error("abstract method;") }
    public function getYBot():Number { throw new Error("abstract method;") }

    public function getXMin():Number { throw new Error("abstract method;") }
    public function getXMax():Number { throw new Error("abstract method;") }

    public function getX0():Number { throw new Error("abstract method;") }
    public function getY0():Number { throw new Error("abstract method;") }
    public function getX1():Number { throw new Error("abstract method;") }
    public function getY1():Number { throw new Error("abstract method;") }

    public function XforY(y:Number):Number { throw new Error("abstract method;") }
    public function TforY(y:Number):Number { throw new Error("abstract method;") }
    public function XforT(t:Number):Number { throw new Error("abstract method;") }
    public function YforT(t:Number):Number { throw new Error("abstract method;") }
    public function dXforT(t:Number, deriv:int):Number { throw new Error("abstract method;") }
    public function dYforT(t:Number, deriv:int):Number { throw new Error("abstract method;") }

    public function nextVertical(t0:Number, t1:Number):Number { throw new Error("abstract method;") }

    public function crossingsFor(x:Number, y:Number):int {
        if(y >= getYTop() && y < getYBot()) {
            if(x < getXMax() && (x < getXMin() || x < XforY(y))) {
                return 1;
            }
        }

        return 0;
    }

    public function accumulateCrossings(c:Crossings):Boolean {
        var xhi:Number = c.getXHi();

        if(getXMin() >= xhi)
            return false;

        var xlo:Number = c.getXLo();
        var ylo:Number = c.getYLo();
        var yhi:Number = c.getYHi();
        var y0:Number = getYTop();
        var y1:Number = getYBot();
        var tstart:Number, ystart:Number, tend:Number, yend:Number;

        if(y0 < ylo) {
            if(y1 <= ylo)
                return false;

            ystart = ylo;
            tstart = TforY(ylo);
        }
        else {
            if(y0 >= yhi)
                return false;

            ystart = y0;
            tstart = 0;
        }

        if(y1 > yhi) {
            yend = yhi;
            tend = TforY(yhi);
        }
        else {
            yend = y1;
            tend = 1;
        }

        var hitLo:Boolean = false;
        var hitHi:Boolean = false;

        while(true) {
            var x:Number = XforT(tstart);
            if(x < xhi) {
                if(hitHi || x > xlo)
                    return true;

                hitLo = true;
            }
            else {
                if(hitLo)
                    return true;

                hitHi = true;
            }

            if(tstart >= tend)
                break;

            tstart = nextVertical(tstart, tend);
        }

        if(hitLo)
            c.record(ystart, yend, direction);

        return false;
    }

    public function enlarge(r:Rectangle2D):void { throw new Error("abstract method;") }

    public function getSubCurve(ystart:Number, yend:Number):Curve {
        return getSubCurveDir(ystart, yend, direction);
    }

    public function getReversedCurve():Curve { throw new Error("abstract method;") }

    public function getSubCurveDir(ystart:Number, yend:Number, dir:int):Curve { throw new Error("abstract method;") }

    public function compareTo(that:Curve, yrange:Vector.<Number>):int {
        var y0:Number = yrange[0];
        var y1:Number = yrange[1];

        y1 = Math.min(Math.min(y1, this.getYBot()), that.getYBot());

        if(y1 <= yrange[0])
            throw new Error("backstepping from " + yrange[0] + " to " + y1);

        yrange[1] = y1;

        if(this.getXMax() <= that.getXMin()) {
            if(this.getXMin() == that.getXMax())
                return 0;

            return -1;
        }

        if(this.getXMin() >= that.getXMax())
            return 1;

        // Parameter s for thi(s) curve and t for tha(t) curve
        // [st]0 = parameters for top of current section of interest
        // [st]1 = parameters for bottom of valid range
        // [st]h = parameters for hypothesis point
        // [d][xy]s = valuations of thi(s) curve at sh
        // [d][xy]t = valuations of tha(t) curve at th
        var s0:Number = this.TforY(y0);
        var ys0:Number = this.YforT(s0);
        if(ys0 < y0) {
            s0 = refineTforY(s0, ys0, y0);
            ys0 = this.YforT(s0);
        }

        var s1:Number = this.TforY(y1);
        if(this.YforT(s1) < y0) {
            s1 = refineTforY(s1, this.YforT(s1), y0);
            //System.out.println("s1 problem!");
        }

        var t0:Number = that.TforY(y0);
        var yt0:Number = that.YforT(t0);
        if(yt0 < y0) {
            t0 = that.refineTforY(t0, yt0, y0);
            yt0 = that.YforT(t0);
        }

        var t1:Number = that.TforY(y1);
        if(that.YforT(t1) < y0) {
            t1 = that.refineTforY(t1, that.YforT(t1), y0);
            //System.out.println("t1 problem!");
        }

        var xs0:Number = this.XforT(s0);
        var xt0:Number = that.XforT(t0);
        var scale:Number = Math.max(Math.abs(y0), Math.abs(y1));
        var ymin:Number = Math.max(scale * 1E-14, 1E-300);

        if(fairlyClose(xs0, xt0)) {
            var bump:Number = ymin;
            var maxbump:Number = Math.min(ymin * 1E13, (y1 - y0) * .1);
            var y:Number = y0 + bump;

            while(y <= y1) {
                if(fairlyClose(this.XforY(y), that.XforY(y))) {
                    if((bump *= 2) > maxbump) {
                        bump = maxbump;
                    }
                }
                else {
                    y -= bump;

                    while(true) {
                        bump /= 2;
                        var newy:Number = y + bump;
                        if(newy <= y)
                            break;

                        if(fairlyClose(this.XforY(newy), that.XforY(newy)))
                            y = newy;
                    }
                    break;
                }

                y += bump;
            }

            if(y > y0) {
                if(y < y1)
                    yrange[1] = y;

                return 0;
            }
        }

        while(s0 < s1 && t0 < t1) {
            var sh:Number = this.nextVertical(s0, s1);
            var xsh:Number = this.XforT(sh);
            var ysh:Number = this.YforT(sh);
            var th:Number = that.nextVertical(t0, t1);
            var xth:Number = that.XforT(th);
            var yth:Number = that.YforT(th);

            try {
                if(findIntersect(that, yrange, ymin, 0, 0,
                    s0, xs0, ys0, sh, xsh, ysh,
                    t0, xt0, yt0, th, xth, yth)) {
                    break;
                }
            } catch(t:Error) {
                return 0;
            }

            if(ysh < yth) {
                if(ysh > yrange[0]) {
                    if(ysh < yrange[1]) {
                        yrange[1] = ysh;
                    }
                    break;
                }

                s0 = sh;
                xs0 = xsh;
                ys0 = ysh;
            }
            else {
                if(yth > yrange[0]) {
                    if(yth < yrange[1])
                        yrange[1] = yth;

                    break;
                }

                t0 = th;
                xt0 = xth;
                yt0 = yth;
            }
        }

        var ymid:Number = (yrange[0] + yrange[1]) / 2;

        return orderof(this.XforY(ymid), that.XforY(ymid));
    }

    public static const TMIN:Number= 1E-3;

    public function findIntersect(that:Curve, yrange:Vector.<Number>, ymin:Number, slevel:int, tlevel:int, s0:Number, xs0:Number, ys0:Number, s1:Number, xs1:Number, ys1:Number, t0:Number, xt0:Number, yt0:Number, t1:Number, xt1:Number, yt1:Number):Boolean {
        if(ys0 > yt1 || yt0 > ys1)
            return false;

        if(Math.min(xs0, xs1) > Math.max(xt0, xt1) ||
           Math.max(xs0, xs1) < Math.min(xt0, xt1))
            return false;

        // Bounding boxes intersect - back off the larger of
        // the two subcurves by half until they stop intersecting
        // (or until they get small enough to switch to a more
        //  intensive algorithm).
        var s:Number, t:Number, xt:Number, yt:Number;
        if(s1 - s0 > TMIN) {
            s = (s0 + s1) / 2;
            var xs:Number = this.XforT(s);
            var ys:Number = this.YforT(s);

            if(s == s0 || s == s1)
                throw new Error("no s progress!");

            if(t1 - t0 > TMIN) {
                t = (t0 + t1) / 2;
                xt = that.XforT(t);
                yt = that.YforT(t);
                if(t == t0 || t == t1)
                    throw new Error("no t progress!");

                if(ys >= yt0 && yt >= ys0) {
                    if(findIntersect(that, yrange, ymin, slevel + 1, tlevel + 1, s0, xs0, ys0, s, xs, ys, t0, xt0, yt0, t, xt, yt))
                        return true;
                }

                if(ys >= yt) {
                    if(findIntersect(that, yrange, ymin, slevel + 1, tlevel + 1, s0, xs0, ys0, s, xs, ys, t, xt, yt, t1, xt1, yt1))
                        return true;
                }

                if(yt >= ys) {
                    if(findIntersect(that, yrange, ymin, slevel + 1, tlevel + 1, s, xs, ys, s1, xs1, ys1, t0, xt0, yt0, t, xt, yt))
                        return true;
                }
                if(ys1 >= yt && yt1 >= ys) {
                    if(findIntersect(that, yrange, ymin, slevel + 1, tlevel + 1, s, xs, ys, s1, xs1, ys1, t, xt, yt, t1, xt1, yt1))
                        return true;
                }
            }
            else {
                if(ys >= yt0) {
                    if(findIntersect(that, yrange, ymin, slevel + 1, tlevel, s0, xs0, ys0, s, xs, ys, t0, xt0, yt0, t1, xt1, yt1))
                        return true;
                }
                if(yt1 >= ys) {
                    if(findIntersect(that, yrange, ymin, slevel + 1, tlevel, s, xs, ys, s1, xs1, ys1, t0, xt0, yt0, t1, xt1, yt1))
                        return true;
                }
            }
        }
        else if(t1 - t0 > TMIN) {
            t = (t0 + t1) / 2;
            xt = that.XforT(t);
            yt = that.YforT(t);

            if(t == t0 || t == t1)
                throw new Error("no t progress!");

            if(yt >= ys0) {
                if(findIntersect(that, yrange, ymin, slevel, tlevel + 1, s0, xs0, ys0, s1, xs1, ys1, t0, xt0, yt0, t, xt, yt))
                    return true;
            }

            if(ys1 >= yt) {
                if(findIntersect(that, yrange, ymin, slevel, tlevel + 1, s0, xs0, ys0, s1, xs1, ys1, t, xt, yt, t1, xt1, yt1))
                    return true;
            }
        }
        else {
            // No more subdivisions
            var xlk:Number = xs1 - xs0;
            var ylk:Number = ys1 - ys0;
            var xnm:Number = xt1 - xt0;
            var ynm:Number = yt1 - yt0;
            var xmk:Number = xt0 - xs0;
            var ymk:Number = yt0 - ys0;
            var det:Number = xnm * ylk - ynm * xlk;

            if(det != 0) {
                var detinv:Number = 1 / det;
                s = (xnm * ymk - ynm * xmk) * detinv;
                t = (xlk * ymk - ylk * xmk) * detinv;
                if(s >= 0 && s <= 1 && t >= 0 && t <= 1) {
                    s = s0 + s * (s1 - s0);
                    t = t0 + t * (t1 - t0);
                    if(s < 0 || s > 1 || t < 0 || t > 1) {
                        //System.out.println("Uh oh!");
                    }

                    var y:Number = (this.YforT(s) + that.YforT(t)) / 2;
                    if(y <= yrange[1] && y > yrange[0]) {
                        yrange[1] = y;
                        return true;
                    }
                }
            }
            //System.out.println("Testing lines!");
        }

        return false;
    }

    public function refineTforY(t0:Number, yt0:Number, y0:Number):Number {
        var t1:Number = 1;

        while(true) {
            var th:Number = (t0 + t1) / 2;
            if(th == t0 || th == t1)
                return t1;

            var y:Number = YforT(th);

            if(y < y0) {
                t0 = th;
                yt0 = y;
            }
            else if(y > y0) {
                t1 = th;
            }
            else {
                return t1;
            }
        }

        // to silence compiler warning
        return NaN;
    }

    public function fairlyClose(v1:Number, v2:Number):Boolean {
        var absV1:Number = Math.abs(v1);
        var absV2:Number = Math.abs(v2);
        var maxAbs:Number = absV1 > absV2 ? absV1 : absV2;

        return (Math.abs(v1 - v2) < maxAbs * 1E-10);
    }

    public function getSegment(coords:Vector.<Point2D>):SegmentType { throw new Error("abstract method"); }
}
}
