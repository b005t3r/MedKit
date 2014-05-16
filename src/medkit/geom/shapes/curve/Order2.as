/**
 * User: booster
 * Date: 15/05/14
 * Time: 15:55
 */
package medkit.geom.shapes.curve {
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.enum.SegmentType;

public class Order2 extends Curve {
    private static const _tmp:Vector.<Number> = new Vector.<Number>(1, true);

    private var x0:Number;
    private var y0:Number;
    private var cx0:Number;
    private var cy0:Number;
    private var x1:Number;
    private var y1:Number;
    private var xmin:Number;
    private var xmax:Number;

    private var xcoeff0:Number;
    private var xcoeff1:Number;
    private var xcoeff2:Number;
    private var ycoeff0:Number;
    private var ycoeff1:Number;
    private var ycoeff2:Number;

    public static function insert(curves:Vector.<Curve>, tmp:Vector.<Point2D>, x0:Number, y0:Number, cx0:Number, cy0:Number, x1:Number, y1:Number, direction:int):void {
        var numparams:int = getHorizontalParams(y0, cy0, y1, _tmp);

        if(numparams == 0) {
            // We are using addInstance here to avoid inserting horisontal
            // segments
            addInstance(curves, x0, y0, cx0, cy0, x1, y1, direction);
            return;
        }

        // assert(numparams == 1);
        var t:Number = _tmp[0];

        tmp[0].x = x0;
        tmp[0].y = y0;
        tmp[1].x = cx0;
        tmp[1].y = cy0;
        tmp[2].x = x1;
        tmp[2].y = y1;

        split(tmp, 0, t);

        var i0:int = (direction == INCREASING) ? 0 : 2;
        var i1:int = 2 - i0;

        addInstance(curves, tmp[i0].x, tmp[i0].y, tmp[i0 + 1].x, tmp[i0 + 1].y, tmp[i0 + 2].x, tmp[i0 + 2].y, direction);
        addInstance(curves, tmp[i1].x, tmp[i1].y, tmp[i1 + 1].x, tmp[i1 + 1].y, tmp[i1 + 2].x, tmp[i1 + 2].y, direction);
    }

    public static function addInstance(curves:Vector.<Curve>, x0:Number, y0:Number, cx0:Number, cy0:Number, x1:Number, y1:Number, direction:int):void {
        if(y0 > y1)
            curves[curves.length] = new Order2(x1, y1, cx0, cy0, x0, y0, -direction);
        else if(y1 > y0)
            curves[curves.length] = new Order2(x0, y0, cx0, cy0, x1, y1, direction);
    }

    /*
     * Return the count of the number of horizontal sections of the
     * specified quadratic Bezier curve.  Put the parameters for the
     * horizontal sections into the specified <code>ret</code> array.
     * <p>
     * If we examine the parametric equation in t, we have:
     *     Py(t) = C0*(1-t)^2 + 2*CP*t*(1-t) + C1*t^2
     *           = C0 - 2*C0*t + C0*t^2 + 2*CP*t - 2*CP*t^2 + C1*t^2
     *           = C0 + (2*CP - 2*C0)*t + (C0 - 2*CP + C1)*t^2
     *     Py(t) = (C0 - 2*CP + C1)*t^2 + (2*CP - 2*C0)*t + (C0)
     * If we take the derivative, we get:
     *     Py(t) = At^2 + Bt + C
     *     dPy(t) = 2At + B = 0
     *     2*(C0 - 2*CP + C1)t + 2*(CP - C0) = 0
     *     2*(C0 - 2*CP + C1)t = 2*(C0 - CP)
     *     t = 2*(C0 - CP) / 2*(C0 - 2*CP + C1)
     *     t = (C0 - CP) / (C0 - CP + C1 - CP)
     * Note that this method will return 0 if the equation is a line,
     * which is either always horizontal or never horizontal.
     * Completely horizontal curves need to be eliminated by other
     * means outside of this method.
     */
    public static function getHorizontalParams(c0:Number, cp:Number, c1:Number, ret:Vector.<Number>):int {
        if(c0 <= cp && cp <= c1)
            return 0;

        c0 -= cp;
        c1 -= cp;

        var denom:Number = c0 + c1;

        // If denom == 0 then cp == (c0+c1)/2 and we have a line.
        if(denom == 0)
            return 0;

        var t:Number = c0 / denom;

        // No splits at t==0 and t==1
        if(t <= 0 || t >= 1)
            return 0;

        ret[0] = t;

        return 1;
    }

    /*
     * Split the quadratic Bezier stored at coords[pos...pos+5] representing
     * the paramtric range [0..1] into two subcurves representing the
     * parametric subranges [0..t] and [t..1].  Store the results back
     * into the array at coords[pos...pos+5] and coords[pos+4...pos+9].
     */
    public static function split(coords:Vector.<Point2D>, pos:int, t:Number):void {
        var x0:Number, y0:Number, cx:Number, cy:Number, x1:Number, y1:Number;

        coords[pos + 4].x = x1 = coords[pos + 2].x;
        coords[pos + 4].y = y1 = coords[pos + 2].y;
        cx = coords[pos + 1].x;
        cy = coords[pos + 1].x;
        x1 = cx + (x1 - cx) * t;
        y1 = cy + (y1 - cy) * t;
        x0 = coords[pos + 0].x;
        y0 = coords[pos + 0].y;
        x0 = x0 + (cx - x0) * t;
        y0 = y0 + (cy - y0) * t;
        cx = x0 + (x1 - x0) * t;
        cy = y0 + (y1 - y0) * t;
        coords[pos + 1].x = x0;
        coords[pos + 1].y = y0;
        coords[pos + 2].x = cx;
        coords[pos + 2].y = cy;
        coords[pos + 3].x = x1;
        coords[pos + 3].y = y1;
    }

    public function Order2(x0:Number, y0:Number, cx0:Number, cy0:Number, x1:Number, y1:Number, direction:int) {
        super(direction);
        // REMIND: Better accuracy in the root finding methods would
        //  ensure that cy0 is in range.  As it stands, it is never
        //  more than "1 mantissa bit" out of range...
        if(cy0 < y0)
            cy0 = y0;
        else if(cy0 > y1)
            cy0 = y1;

        this.x0 = x0;
        this.y0 = y0;
        this.cx0 = cx0;
        this.cy0 = cy0;
        this.x1 = x1;
        this.y1 = y1;

        var tmp:Number;

        tmp = x0 < x1 ? x0 : x1;
        xmin = tmp < cx0 ? tmp : cx0;
        tmp = x0 > x1 ? x0 : x1;
        xmax = tmp > cx0 ? tmp : cx0;
        xcoeff0 = x0;
        xcoeff1 = cx0 + cx0 - x0 - x0;
        xcoeff2 = x0 - cx0 - cx0 + x1;
        ycoeff0 = y0;
        ycoeff1 = cy0 + cy0 - y0 - y0;
        ycoeff2 = y0 - cy0 - cy0 + y1;
    }

    override public function getOrder():int { return 2; }

    override public function getXTop():Number { return x0; }
    override public function getYTop():Number { return y0; }

    override public function getXBot():Number { return x1; }
    override public function getYBot():Number { return y1; }

    override public function getXMin():Number { return xmin; }
    override public function getXMax():Number { return xmax; }

    override public function getX0():Number {
        return (direction == INCREASING) ? x0 : x1;
    }

    override public function getY0():Number {
        return (direction == INCREASING) ? y0 : y1;
    }

    public function getCX0():Number { return cx0; }
    public function getCY0():Number { return cy0; }

    override public function getX1():Number {
        return (direction == DECREASING) ? x0 : x1;
    }

    override public function getY1():Number {
        return (direction == DECREASING) ? y0 : y1;
    }

    override public function XforY(y:Number):Number {
        if(y <= y0) {
            return x0;
        }
        if(y >= y1) {
            return x1;
        }
        return XforT(TforY(y));
    }

    override public function TforY(y:Number):Number {
        if(y <= y0)
            return 0;

        if(y >= y1)
            return 1;

        return Order2.TforY(y, ycoeff0, ycoeff1, ycoeff2);
    }

    public static function TforY(y:Number, ycoeff0:Number, ycoeff1:Number, ycoeff2:Number):Number {
        var root:Number;

        // The caller should have already eliminated y values
        // outside of the y0 to y1 range.
        ycoeff0 -= y;

        if(ycoeff2 == 0.0) {
            // The quadratic parabola has degenerated to a line.
            // ycoeff1 should not be 0.0 since we have already eliminated
            // totally horizontal lines, but if it is, then we will generate
            // infinity here for the root, which will not be in the [0,1]
            // range so we will pass to the failure code below.
            root = -ycoeff0 / ycoeff1;

            if(root >= 0 && root <= 1)
                return root;
        }
        else {
            // From Numerical Recipes, 5.6, Quadratic and Cubic Equations
            var d:Number = ycoeff1 * ycoeff1 - 4.0 * ycoeff2 * ycoeff0;

            // If d < 0.0, then there are no roots
            if(d >= 0.0) {
                d = Math.sqrt(d);
                // For accuracy, calculate one root using:
                //     (-ycoeff1 +/- d) / 2ycoeff2
                // and the other using:
                //     2ycoeff0 / (-ycoeff1 +/- d)
                // Choose the sign of the +/- so that ycoeff1+d
                // gets larger in magnitude

                if(ycoeff1 < 0.0)
                    d = -d;

                var q:Number = (ycoeff1 + d) / -2.0;

                // We already tested ycoeff2 for being 0 above
                root = q / ycoeff2;

                if(root >= 0 && root <= 1) {
                    return root;
                }

                if(q != 0.0) {
                    root = ycoeff0 / q;

                    if(root >= 0 && root <= 1)
                        return root;
                }
            }
        }
        /* We failed to find a root in [0,1].  What could have gone wrong?
         * First, remember that these curves are constructed to be monotonic
         * in Y and totally horizontal curves have already been eliminated.
         * Now keep in mind that the Y coefficients of the polynomial form
         * of the curve are calculated from the Y coordinates which define
         * our curve.  They should theoretically define the same curve,
         * but they can be off by a couple of bits of precision after the
         * math is done and so can represent a slightly modified curve.
         * This is normally not an issue except when we have solutions near
         * the endpoints.  Since the answers we get from solving the polynomial
         * may be off by a few bits that means that they could lie just a
         * few bits of precision outside the [0,1] range.
         *
         * Another problem could be that while the parametric curve defined
         * by the Y coordinates has a local minima or maxima at or just
         * outside of the endpoints, the polynomial form might express
         * that same min/max just inside of and just shy of the Y coordinate
         * of that endpoint.  In that case, if we solve for a Y coordinate
         * at or near that endpoint, we may be solving for a Y coordinate
         * that is below that minima or above that maxima and we would find
         * no solutions at all.
         *
         * In either case, we can assume that y is so near one of the
         * endpoints that we can just collapse it onto the nearest endpoint
         * without losing more than a couple of bits of precision.
         */
        // First calculate the midpoint between y0 and y1 and choose to
        // return either 0.0 or 1.0 depending on whether y is above
        // or below the midpoint...
        // Note that we subtracted y from ycoeff0 above so both y0 and y1
        // will be "relative to y" so we are really just looking at where
        // zero falls with respect to the "relative midpoint" here.
        var y0:Number = ycoeff0;
        var y1:Number = ycoeff0 + ycoeff1 + ycoeff2;

        return (0 < (y0 + y1) / 2) ? 0.0 : 1.0;
    }

    override public function XforT(t:Number):Number {
        return (xcoeff2 * t + xcoeff1) * t + xcoeff0;
    }

    override public function YforT(t:Number):Number {
        return (ycoeff2 * t + ycoeff1) * t + ycoeff0;
    }

    override public function dXforT(t:Number, deriv:int):Number {
        switch(deriv) {
            case 0:
                return (xcoeff2 * t + xcoeff1) * t + xcoeff0;
            case 1:
                return 2 * xcoeff2 * t + xcoeff1;
            case 2:
                return 2 * xcoeff2;
            default:
                return 0;
        }
    }

    override public function dYforT(t:Number, deriv:int):Number {
        switch(deriv) {
            case 0:
                return (ycoeff2 * t + ycoeff1) * t + ycoeff0;
            case 1:
                return 2 * ycoeff2 * t + ycoeff1;
            case 2:
                return 2 * ycoeff2;
            default:
                return 0;
        }
    }

    override public function nextVertical(t0:Number, t1:Number):Number {
        var t:Number = -xcoeff1 / (2 * xcoeff2);

        if(t > t0 && t < t1)
            return t;

        return t1;
    }

    override public function enlarge(r:Rectangle2D):void {
        r.add(x0, y0);

        var t:Number = -xcoeff1 / (2 * xcoeff2);

        if(t > 0 && t < 1)
            r.add(XforT(t), YforT(t));

        r.add(x1, y1);
    }

    override public function getSubCurveDir(ystart:Number, yend:Number, dir:int):Curve {
        var t0:Number, t1:Number;

        if(ystart <= y0) {
            if(yend >= y1)
                return getWithDirection(dir);

            t0 = 0;
        }
        else {
            t0 = Order2.TforY(ystart, ycoeff0, ycoeff1, ycoeff2);
        }

        if(yend >= y1)
            t1 = 1;
        else
            t1 = Order2.TforY(yend, ycoeff0, ycoeff1, ycoeff2);

        var eqn:Vector.<Point2D> = new Vector.<Point2D>(5, true);
        eqn[0] = new Point2D(); eqn[1] = new Point2D(); eqn[2] = new Point2D(); eqn[3] = new Point2D(); eqn[4] = new Point2D();

        eqn[0].x = x0;
        eqn[0].y = y0;
        eqn[1].x = cx0;
        eqn[1].y = cy0;
        eqn[2].x = x1;
        eqn[2].y = y1;

        if(t1 < 1)
            split(eqn, 0, t1);

        var i:int;

        if(t0 <= 0) {
            i = 0;
        }
        else {
            split(eqn, 0, t0 / t1);
            i = 4;
        }

        return new Order2(eqn[i + 0].x, ystart, eqn[i + 1].x, eqn[i + 1].y, eqn[i + 2].x, yend, dir);
    }

    override public function getReversedCurve():Curve {
        return new Order2(x0, y0, cx0, cy0, x1, y1, -direction);
    }

    override public function getSegment(coords:Vector.<Point2D>):SegmentType {
        coords[0].x = cx0;
        coords[0].y = cy0;

        if(direction == INCREASING) {
            coords[1].x = x1;
            coords[1].y = y1;
        }
        else {
            coords[1].x = x0;
            coords[1].y = y0;
        }

        return SegmentType.QuadTo;
    }

    override public function controlPointString():String {
        return ("(" + round(cx0) + ", " + round(cy0) + "), ");
    }
}
}
