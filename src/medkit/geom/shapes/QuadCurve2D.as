/**
 * User: booster
 * Date: 16/05/14
 * Time: 9:56
 */
package medkit.geom.shapes {
import medkit.geom.*;

import flash.geom.Matrix;

import medkit.geom.shapes.QuadCurve2D;

public class QuadCurve2D implements Shape2D {
    private static const BELOW:int      = -2;
    private static const LOWEDGE:int    = -1;
    private static const INSIDE:int     = 0;
    private static const HIGHEDGE:int   = 1;
    private static const ABOVE:int      = 2;

    /**
     * Returns the square of the flatness, or maximum distance of a
     * control point from the line connecting the end points, of the
     * quadratic curve specified by the indicated control points.
     *
     * @param x1 the X coordinate of the start point
     * @param y1 the Y coordinate of the start point
     * @param ctrlx the X coordinate of the control point
     * @param ctrly the Y coordinate of the control point
     * @param x2 the X coordinate of the end point
     * @param y2 the Y coordinate of the end point
     * @return the square of the flatness of the quadratic curve
     *          defined by the specified coordinates.
     * @since 1.2
     */
    public static function getFlatnessSq(x1:Number, y1:Number,
                                         ctrlx:Number, ctrly:Number,
                                         x2:Number, y2:Number):Number{
        //TODO: return Line2D.ptSegDistSq(x1, y1, x2, y2, ctrlx, ctrly);
        throw new Error("not implemented");
    }

    /**
     * Returns the flatness, or maximum distance of a
     * control point from the line connecting the end points, of the
     * quadratic curve specified by the indicated control points.
     *
     * @param x1 the X coordinate of the start point
     * @param y1 the Y coordinate of the start point
     * @param ctrlx the X coordinate of the control point
     * @param ctrly the Y coordinate of the control point
     * @param x2 the X coordinate of the end point
     * @param y2 the Y coordinate of the end point
     * @return the flatness of the quadratic curve defined by the
     *          specified coordinates.
     * @since 1.2
     */
    public static function getFlatness(x1:Number, y1:Number,
                                       ctrlx:Number, ctrly:Number,
                                       x2:Number, y2:Number):Number{
        //TODO: return Line2D.ptSegDist(x1, y1, x2, y2, ctrlx, ctrly);
        throw new Error("not implemented");
    }

    /**
     * Subdivides the quadratic curve specified by the <code>src</code>
     * parameter and stores the resulting two subdivided curves into the
     * <code>left</code> and <code>right</code> curve parameters.
     * Either or both of the <code>left</code> and <code>right</code>
     * objects can be the same as the <code>src</code> object or
     * <code>null</code>.
     *
     * @param src the quadratic curve to be subdivided
     * @param left the <code>QuadCurve2D</code> object for storing the left or first half of the subdivided curve (or null)
     * @param right the <code>QuadCurve2D</code> object for storing the right or second half of the subdivided curve (or null)
     */
    public static function subdivide(src:QuadCurve2D, left:QuadCurve2D, right:QuadCurve2D):void {
        var x1:Number = src.x1;
        var y1:Number = src.y1;
        var ctrlx:Number = src.ctrlx;
        var ctrly:Number = src.ctrly;
        var x2:Number = src.x2;
        var y2:Number = src.y2;

        var ctrlx1:Number = (x1 + ctrlx) / 2.0;
        var ctrly1:Number = (y1 + ctrly) / 2.0;
        var ctrlx2:Number = (x2 + ctrlx) / 2.0;
        var ctrly2:Number = (y2 + ctrly) / 2.0;

        ctrlx = (ctrlx1 + ctrlx2) / 2.0;
        ctrly = (ctrly1 + ctrly2) / 2.0;

        if(left != null)
            left.setTo(x1, y1, ctrlx1, ctrly1, ctrlx, ctrly);

        if(right != null)
            right.setTo(ctrlx, ctrly, ctrlx2, ctrly2, x2, y2);
    }

    /**
     * Solves the quadratic whose coefficients are in the <code>eqn</code>
     * array and places the non-complex roots into the <code>res</code>
     * array, returning the number of roots.
     * The quadratic solved is represented by the equation:
     * <pre>
     *     eqn = {C, B, A};
     *     ax^2 + bx + c = 0
     * </pre>
     * A return value of <code>-1</code> is used to distinguish a constant
     * equation, which might be always 0 or never 0, from an equation that
     * has no zeroes.
     * @param eqn the specified array of coefficients to use to solve the quadratic equation
     * @param res the array that contains the non-complex roots resulting from the solution of the quadratic equation
     * @return the number of roots, or <code>-1</code> if the equation is a constant.
     */
    public static function solveQuadratic(eqn:Vector.<Number>, res:Vector.<Number>):int {
        var a:Number    = eqn[2];
        var b:Number    = eqn[1];
        var c:Number    = eqn[0];
        var roots:int   = 0;

        if(a == 0.0) {
            // The quadratic parabola has degenerated to a line.
            if(b == 0.0) {
                // The line has degenerated to a constant.
                return -1;
            }

            res[roots++] = -c / b;
        }
        else {
            // From Numerical Recipes, 5.6, Quadratic and Cubic Equations
            var d:Number = b * b - 4.0 * a * c;

            // If d < 0.0, then there are no roots
            if(d < 0.0)
                return 0;


            d = Math.sqrt(d);

            // For accuracy, calculate one root using:
            //     (-b +/- d) / 2a
            // and the other using:
            //     2c / (-b +/- d)
            // Choose the sign of the +/- so that b+d gets larger in magnitude
            if(b < 0.0)
                d = -d;

            var q:Number = (b + d) / -2.0;

            // We already tested a for being 0 above
            res[roots++] = q / a;

            if(q != 0.0)
                res[roots++] = c / q;
        }

        return roots;
    }

    /**
     * Fill an array with the coefficients of the parametric equation
     * in t, ready for solving against val with solveQuadratic.
     * We currently have:
     *     val = Py(t) = C1*(1-t)^2 + 2*CP*t*(1-t) + C2*t^2
     *                 = C1 - 2*C1*t + C1*t^2 + 2*CP*t - 2*CP*t^2 + C2*t^2
     *                 = C1 + (2*CP - 2*C1)*t + (C1 - 2*CP + C2)*t^2
     *               0 = (C1 - val) + (2*CP - 2*C1)*t + (C1 - 2*CP + C2)*t^2
     *               0 = C + Bt + At^2
     *     C = C1 - val
     *     B = 2*CP - 2*C1
     *     A = C1 - 2*CP + C2
     */
    private static function fillEqn(eqn:Vector.<Number>, val:Number, c1:Number, cp:Number, c2:Number):void {
        eqn[0] = c1 - val;
        eqn[1] = cp + cp - c1 - c1;
        eqn[2] = c1 - cp - cp + c2;
    }

    /**
     * Evaluate the t values in the first num slots of the vals[] array
     * and place the evaluated values back into the same array.  Only
     * evaluate t values that are within the range <0, 1>, including
     * the 0 and 1 ends of the range iff the include0 or include1
     * booleans are true.  If an "inflection" equation is handed in,
     * then any points which represent a point of inflection for that
     * quadratic equation are also ignored.
     */
    private static function evalQuadratic(vals:Vector.<Number>, num:int, include0:Boolean, include1:Boolean, inflect:Vector.<Number>, c1:Number, ctrl:Number, c2:Number):int {
        var j:int = 0;

        for(var i:int = 0; i < num; i++) {
            var t:Number = vals[i];
            if((include0 ? t >= 0 : t > 0) &&
               (include1 ? t <= 1 : t < 1) &&
               (inflect == null || inflect[1] + 2 * inflect[2] * t != 0)) {
                var u:Number = 1 - t;
                vals[j++] = c1 * u * u + 2 * ctrl * t * u + c2 * t * t;
            }
        }

        return j;
    }

    /**
     * Determine where coord lies with respect to the range from
     * low to high.  It is assumed that low <= high.  The return
     * value is one of the 5 values BELOW, LOWEDGE, INSIDE, HIGHEDGE,
     * or ABOVE.
     */
    private static function getTag(coord:Number, low:Number, high:Number):int {
        if(coord <= low)
            return (coord < low ? BELOW : LOWEDGE);

        if(coord >= high)
            return (coord > high ? ABOVE : HIGHEDGE);

        return INSIDE;
    }

    /**
     * Determine if the pttag represents a coordinate that is already
     * in its test range, or is on the border with either of the two
     * opttags representing another coordinate that is "towards the
     * inside" of that test range.  In other words, are either of the
     * two "opt" points "drawing the pt inward"?
     */
    private static function inwards(pttag:int, opt1tag:int, opt2tag:int):Boolean {
        switch(pttag) {
            case LOWEDGE:
                return (opt1tag >= INSIDE || opt2tag >= INSIDE);

            case INSIDE:
                return true;

            case HIGHEDGE:
                return (opt1tag <= INSIDE || opt2tag <= INSIDE);

            case BELOW:
            case ABOVE:
            default:
                return false;
        }
    }

    /** The X coordinate of the start point of the quadratic curve segment. */
    public var x1:Number;

    /** The Y coordinate of the start point of the quadratic curve segment. */
    public var y1:Number;

    /** The X coordinate of the control point of the quadratic curve segment. */
    public var ctrlx:Number;

    /** The Y coordinate of the control point of the quadratic curve segment. */
    public var ctrly:Number;

    /** The X coordinate of the end point of the quadratic curve segment. */
    public var x2:Number;

    /** The Y coordinate of the end point of the quadratic curve segment. */
    public var y2:Number;

    public function QuadCurve2D(x1:Number, y1:Number, ctrlx:Number, ctrly:Number, x2:Number, y2:Number) {
        setTo(x1, y1, ctrlx, ctrly, x2, y2);
    }

    public function getBounds(result:Rectangle2D = null):Rectangle2D {
        if(result == null) result = new Rectangle2D();

        var tmp:Number;

        tmp                 = x1 < x2 ? x1 : x2;
        var left:Number     = tmp < ctrlx ? tmp : ctrlx;
        tmp                 = y1 < y2 ? y1 : y2;
        var top:Number      = tmp < ctrly ? tmp : ctrly;
        tmp                 = x1 > x2 ? x1 : x2;
        var right:Number    = tmp > ctrlx ? tmp : ctrlx;
        tmp                 = y1 > y2 ? y1 : y2;
        var bottom:Number   = tmp > ctrly ? tmp : ctrly;

        result.setTo(left, top, right - left, bottom - top);

        return result;
    }

    public function intersectsRect(x:Number, y:Number, w:Number, h:Number):Boolean{
        // Trivially reject non-existant rectangles
        if(w <= 0 || h <= 0)
            return false;

        // Trivially accept if either endpoint is inside the rectangle
        // (not on its border since it may end there and not go inside)
        // Record where they lie with respect to the rectangle.
        //     -1 => left, 0 => inside, 1 => right
        var x1tag:int = getTag(x1, x, x + w);
        var y1tag:int = getTag(y1, y, y + h);

        if(x1tag == INSIDE && y1tag == INSIDE)
            return true;

        var x2tag:int = getTag(x2, x, x + w);
        var y2tag:int = getTag(y2, y, y + h);

        if(x2tag == INSIDE && y2tag == INSIDE)
            return true;

        var ctrlxtag:int = getTag(ctrlx, x, x + w);
        var ctrlytag:int = getTag(ctrly, y, y + h);

        // Trivially reject if all points are entirely to one side of
        // the rectangle.
        if(x1tag < INSIDE && x2tag < INSIDE && ctrlxtag < INSIDE)
            return false;       // All points left

        if(y1tag < INSIDE && y2tag < INSIDE && ctrlytag < INSIDE)
            return false;       // All points above

        if(x1tag > INSIDE && x2tag > INSIDE && ctrlxtag > INSIDE)
            return false;       // All points right

        if(y1tag > INSIDE && y2tag > INSIDE && ctrlytag > INSIDE)
            return false;       // All points below

        // Test for endpoints on the edge where either the segment
        // or the curve is headed "inwards" from them
        // Note: These tests are a superset of the fast endpoint tests
        //       above and thus repeat those tests, but take more time
        //       and cover more cases
        if (inwards(x1tag, x2tag, ctrlxtag) && inwards(y1tag, y2tag, ctrlytag))
        {
            // First endpoint on border with either edge moving inside
            return true;
        }
        if (inwards(x2tag, x1tag, ctrlxtag) && inwards(y2tag, y1tag, ctrlytag))
        {
            // Second endpoint on border with either edge moving inside
            return true;
        }

        // Trivially accept if endpoints span directly across the rectangle
        var xoverlap:Boolean= (x1tag * x2tag <= 0);
        var yoverlap:Boolean= (y1tag * y2tag <= 0);

        if (x1tag == INSIDE && x2tag == INSIDE && yoverlap)
            return true;

        if (y1tag == INSIDE && y2tag == INSIDE && xoverlap)
            return true;

        // We now know that both endpoints are outside the rectangle
        // but the 3 points are not all on one side of the rectangle.
        // Therefore the curve cannot be contained inside the rectangle,
        // but the rectangle might be contained inside the curve, or
        // the curve might intersect the boundary of the rectangle.

        var eqn:Vector.<Number> = new Vector.<Number>(3, true);
        var res:Vector.<Number> = new Vector.<Number>(3, true);

        if(! yoverlap) {
            // Both Y coordinates for the closing segment are above or
            // below the rectangle which means that we can only intersect
            // if the curve crosses the top (or bottom) of the rectangle
            // in more than one place and if those crossing locations
            // span the horizontal range of the rectangle.
            fillEqn(eqn, (y1tag < INSIDE ? y : y + h), y1, ctrly, y2);

            return (solveQuadratic(eqn, res) == 2 &&
                    evalQuadratic(res, 2, true, true, null, x1, ctrlx, x2) == 2 &&
                    getTag(res[0], x, x + w) * getTag(res[1], x, x + w) <= 0);
        }

        // Y ranges overlap.  Now we examine the X ranges
        if(!xoverlap) {
            // Both X coordinates for the closing segment are left of
            // or right of the rectangle which means that we can only
            // intersect if the curve crosses the left (or right) edge
            // of the rectangle in more than one place and if those
            // crossing locations span the vertical range of the rectangle.
            fillEqn(eqn, (x1tag < INSIDE ? x : x + w), x1, ctrlx, x2);

            return (solveQuadratic(eqn, res) == 2 &&
                    evalQuadratic(res, 2, true, true, null, y1, ctrly, y2) == 2 &&
                    getTag(res[0], y, y + h) * getTag(res[1], y, y + h) <= 0);
        }

        // The X and Y ranges of the endpoints overlap the X and Y
        // ranges of the rectangle, now find out how the endpoint
        // line segment intersects the Y range of the rectangle
        var dx:Number = x2 - x1;
        var dy:Number = y2 - y1;
        var k:Number = y2 * x1 - x2 * y1;
        var c1tag:int, c2tag:int;

        if(y1tag == INSIDE)
            c1tag = x1tag;
        else
            c1tag = getTag((k + dx * (y1tag < INSIDE ? y : y + h)) / dy, x, x + w);

        if(y2tag == INSIDE)
            c2tag = x2tag;
        else
            c2tag = getTag((k + dx * (y2tag < INSIDE ? y : y + h)) / dy, x, x + w);

        // If the part of the line segment that intersects the Y range
        // of the rectangle crosses it horizontally - trivially accept
        if(c1tag * c2tag <= 0)
            return true;

        // Now we know that both the X and Y ranges intersect and that
        // the endpoint line segment does not directly cross the rectangle.
        //
        // We can almost treat this case like one of the cases above
        // where both endpoints are to one side, except that we will
        // only get one intersection of the curve with the vertical
        // side of the rectangle.  This is because the endpoint segment
        // accounts for the other intersection.
        //
        // (Remember there is overlap in both the X and Y ranges which
        //  means that the segment must cross at least one vertical edge
        //  of the rectangle - in particular, the "near vertical side" -
        //  leaving only one intersection for the curve.)
        //
        // Now we calculate the y tags of the two intersections on the
        // "near vertical side" of the rectangle.  We will have one with
        // the endpoint segment, and one with the curve.  If those two
        // vertical intersections overlap the Y range of the rectangle,
        // we have an intersection.  Otherwise, we don't.

        // c1tag = vertical intersection class of the endpoint segment
        //
        // Choose the y tag of the endpoint that was not on the same
        // side of the rectangle as the subsegment calculated above.
        // Note that we can "steal" the existing Y tag of that endpoint
        // since it will be provably the same as the vertical intersection.
        c1tag = ((c1tag * x1tag <= 0) ? y1tag : y2tag);

        // c2tag = vertical intersection class of the curve
        //
        // We have to calculate this one the straightforward way.
        // Note that the c2tag can still tell us which vertical edge
        // to test against.
        fillEqn(eqn, (c2tag < INSIDE ? x : x+w), x1, ctrlx, x2);
        var num:int = solveQuadratic(eqn, res);

        // Note: We should be able to assert(num == 2); since the
        // X range "crosses" (not touches) the vertical boundary,
        // but we pass num to evalQuadratic for completeness.
        evalQuadratic(res, num, true, true, null, y1, ctrly, y2);

        // Note: We can assert(num evals == 1); since one of the
        // 2 crossings will be out of the [0,1] range.
        c2tag = getTag(res[0], y, y + h);

        // Finally, we have an intersection if the two crossings
        // overlap the Y range of the rectangle.
        return (c1tag * c2tag <= 0);
    }

    public function intersectsRectangle2D(rect:Rectangle2D):Boolean {
        return intersectsRect(rect.x, rect.y, rect.width, rect.height);
    }

    public function contains(x:Number, y:Number):Boolean {
        /*
         * We have a convex shape bounded by quad curve Pc(t)
         * and ine Pl(t).
         *
         *     P1 = (x1, y1) - start point of curve
         *     P2 = (x2, y2) - end point of curve
         *     Pc = (xc, yc) - control point
         *
         *     Pq(t) = P1*(1 - t)^2 + 2*Pc*t*(1 - t) + P2*t^2 =
         *           = (P1 - 2*Pc + P2)*t^2 + 2*(Pc - P1)*t + P1
         *     Pl(t) = P1*(1 - t) + P2*t
         *     t = [0:1]
         *
         *     P = (x, y) - point of interest
         *
         * Let's look at second derivative of quad curve equation:
         *
         *     Pq''(t) = 2 * (P1 - 2 * Pc + P2) = Pq''
         *     It's constant vector.
         *
         * Let's draw a line through P to be parallel to this
         * vector and find the intersection of the quad curve
         * and the line.
         *
         * Pq(t) is point of intersection if system of equations
         * below has the solution.
         *
         *     L(s) = P + Pq''*s == Pq(t)
         *     Pq''*s + (P - Pq(t)) == 0
         *
         *     | xq''*s + (x - xq(t)) == 0
         *     | yq''*s + (y - yq(t)) == 0
         *
         * This system has the solution if rank of its matrix equals to 1.
         * That is, determinant of the matrix should be zero.
         *
         *     (y - yq(t))*xq'' == (x - xq(t))*yq''
         *
         * Let's solve this equation with 't' variable.
         * Also let kx = x1 - 2*xc + x2
         *          ky = y1 - 2*yc + y2
         *
         *     t0q = (1/2)*((x - x1)*ky - (y - y1)*kx) /
         *                 ((xc - x1)*ky - (yc - y1)*kx)
         *
         * Let's do the same for our line Pl(t):
         *
         *     t0l = ((x - x1)*ky - (y - y1)*kx) /
         *           ((x2 - x1)*ky - (y2 - y1)*kx)
         *
         * It's easy to check that t0q == t0l. This fact means
         * we can compute t0 only one time.
         *
         * In case t0 < 0 or t0 > 1, we have an intersections outside
         * of shape bounds. So, P is definitely out of shape.
         *
         * In case t0 is inside [0:1], we should calculate Pq(t0)
         * and Pl(t0). We have three points for now, and all of them
         * lie on one line. So, we just need to detect, is our point
         * of interest between points of intersections or not.
         *
         * If the denominator in the t0q and t0l equations is
         * zero, then the points must be collinear and so the
         * curve is degenerate and encloses no area.  Thus the
         * result is false.
         */
        var kx:Number = x1 - 2 * ctrlx + x2;
        var ky:Number = y1 - 2 * ctrly + y2;
        var dx:Number = x - x1;
        var dy:Number = y - y1;
        var dxl:Number = x2 - x1;
        var dyl:Number = y2 - y1;

        var t0:Number = (dx * ky - dy * kx) / (dxl * ky - dyl * kx);
        if(t0 < 0 || t0 > 1 || t0 != t0) {
            return false;
        }

        var xb:Number = kx * t0 * t0 + 2 * (ctrlx - x1) * t0 + x1;
        var yb:Number = ky * t0 * t0 + 2 * (ctrly - y1) * t0 + y1;
        var xl:Number = dxl * t0 + x1;
        var yl:Number = dyl * t0 + y1;

        return (x >= xb && x < xl) ||
               (x >= xl && x < xb) ||
               (y >= yb && y < yl) ||
               (y >= yl && y < yb);
    }

    public function containsPoint2D(point:Point2D):Boolean {
        return contains(point.x, point.y);
    }

    public function containsRect(x:Number, y:Number, w:Number, h:Number):Boolean {
        if(w <= 0 || h <= 0)
            return false;

        // Assertion: Quadratic curves closed by connecting their endpoints are always convex.
        return (contains(x, y) && contains(x + w, y) && contains(x + w, y + h) && contains(x, y + h));
    }

    public function containsRectangle2D(rect:Rectangle2D):Boolean {
        return containsRect(rect.x, rect.y, rect.width, rect.height);
    }

    public function getPathIterator(transformMatrix:Matrix = null, flatness:Number = 0):PathIterator {
        // TODO: implement
        //if(flatness == 0)
        //    return new QuadIterator(this, transformMatrix);
        //
        //return FlatteningPathIterator(getPathIterator(transformMatrix), flatness);
        throw new Error("not implemented");
    }

    public function setTo(x1:Number, y1:Number, ctrlx:Number, ctrly:Number, x2:Number, y2:Number):void {
        this.x1 = x1;
        this.y1 = y1;
        this.ctrlx = ctrlx;
        this.ctrly = ctrly;
        this.x2 = x2;
        this.y2 = y2;
    }

    /**
     * Returns the square of the flatness, or maximum distance of a
     * control point from the line connecting the end points, of this
     * <code>QuadCurve2D</code>.
     * @return the square of the flatness of this <code>QuadCurve2D</code>.
     */
    public function getFlatnessSq():Number{
        return QuadCurve2D.getFlatnessSq(x1, y1, ctrlx, ctrly, x2, y2);
    }

    /**
     * Returns the flatness, or maximum distance of a
     * control point from the line connecting the end points, of this
     * <code>QuadCurve2D</code>.
     * @return the flatness of this <code>QuadCurve2D</code>.
     */
    public function getFlatness():Number{
        return QuadCurve2D.getFlatness(x1, y1, ctrlx, ctrly, x2, y2);
    }

    /**
     * Subdivides this <code>QuadCurve2D</code> and stores the resulting
     * two subdivided curves into the <code>left</code> and
     * <code>right</code> curve parameters.
     * Either or both of the <code>left</code> and <code>right</code>
     * objects can be the same as this <code>QuadCurve2D</code> or
     * <code>null</code>.
     *
     * @param left the <code>QuadCurve2D</code> object for storing the left or first half of the subdivided curve
     * @param right the <code>QuadCurve2D</code> object for storing the right or second half of the subdivided curve
     */
    public function subdivide(left:QuadCurve2D, right:QuadCurve2D):void {
        QuadCurve2D.subdivide(this, left, right);
    }
}
}
