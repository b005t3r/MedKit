/**
 * User: booster
 * Date: 15/05/14
 * Time: 16:21
 */
package medkit.geom.shapes.curve {
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.QuadCurve2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.enum.SegmentType;

public class Order3 extends Curve {
    private static const _tmp:Vector.<Number> = new Vector.<Number>(3, true);

    private var x0:Number;
    private var y0:Number;
    private var cx0:Number;
    private var cy0:Number;
    private var cx1:Number;
    private var cy1:Number;
    private var x1:Number;
    private var y1:Number;

    private var xmin:Number;
    private var xmax:Number;

    private var xcoeff0:Number;
    private var xcoeff1:Number;
    private var xcoeff2:Number;
    private var xcoeff3:Number;

    private var ycoeff0:Number;
    private var ycoeff1:Number;
    private var ycoeff2:Number;
    private var ycoeff3:Number;

    // !!! I have no idea if this is implemented correctly, check with the original source code !!!!
    public static function insert(curves:Vector.<Curve>, tmp:Vector.<Point2D>, x0:Number, y0:Number, cx0:Number, cy0:Number, cx1:Number, cy1:Number, x1:Number, y1:Number, direction:int):void {
        var numparams:int = getHorizontalParams(y0, cy0, cy1, y1, _tmp);

        if(numparams == 0) {
            // We are using addInstance here to avoid inserting horisontal
            // segments
            addInstance(curves, x0, y0, cx0, cy0, cx1, cy1, x1, y1, direction);
            return;
        }

        // Store coordinates for splitting at tmp[3..10]
        tmp[0].x = x0;
        tmp[0].y = y0;
        tmp[1].x = cx0;
        tmp[1].y = cy0;
        tmp[2].x = cx1;
        tmp[2].y = cy1;
        tmp[3].x = x1;
        tmp[3].y = y1;

        var t:Number = _tmp[0];

        if(numparams > 1 && t > _tmp[1]) {
            // Perform a "2 element sort"...
            _tmp[0] = _tmp[1];
            _tmp[1] = t;
            t = _tmp[0];
        }

        split(tmp, 0, t);

        if(numparams > 1) {
            // Recalculate tmp[1] relative to the range [tmp[0]...1]
            t = (_tmp[1] - t) / (1 - t);
            split(tmp, 3, t);
        }

        var index:int = 0;

        if(direction == DECREASING)
            index += numparams * 3;

        while(numparams >= 0) {
            addInstance(curves, tmp[index + 0].x, tmp[index + 0].y, tmp[index + 1].x, tmp[index + 1].y, tmp[index + 2].x, tmp[index + 2].y, tmp[index + 3].x, tmp[index + 3].y, direction);
            numparams--;

            if(direction == INCREASING)
                index += 3;
            else
                index -= 3;
        }
    }

    public static function addInstance(curves:Vector.<Curve>, x0:Number, y0:Number, cx0:Number, cy0:Number, cx1:Number, cy1:Number, x1:Number, y1:Number, direction:int):void {
        if(y0 > y1)
            curves[curves.length] = new Order3(x1, y1, cx1, cy1, cx0, cy0, x0, y0, -direction);
        else if(y1 > y0)
            curves[curves.length] = new Order3(x0, y0, cx0, cy0, cx1, cy1, x1, y1, direction);

    }

    /*
     * Return the count of the number of horizontal sections of the
     * specified cubic Bezier curve.  Put the parameters for the
     * horizontal sections into the specified <code>ret</code> array.
     * <p>
     * If we examine the parametric equation in t, we have:
     *   Py(t) = C0(1-t)^3 + 3CP0 t(1-t)^2 + 3CP1 t^2(1-t) + C1 t^3
     *         = C0 - 3C0t + 3C0t^2 - C0t^3 +
     *           3CP0t - 6CP0t^2 + 3CP0t^3 +
     *           3CP1t^2 - 3CP1t^3 +
     *           C1t^3
     *   Py(t) = (C1 - 3CP1 + 3CP0 - C0) t^3 +
     *           (3C0 - 6CP0 + 3CP1) t^2 +
     *           (3CP0 - 3C0) t +
     *           (C0)
     * If we take the derivative, we get:
     *   Py(t) = Dt^3 + At^2 + Bt + C
     *   dPy(t) = 3Dt^2 + 2At + B = 0
     *        0 = 3*(C1 - 3*CP1 + 3*CP0 - C0)t^2
     *          + 2*(3*CP1 - 6*CP0 + 3*C0)t
     *          + (3*CP0 - 3*C0)
     *        0 = 3*(C1 - 3*CP1 + 3*CP0 - C0)t^2
     *          + 3*2*(CP1 - 2*CP0 + C0)t
     *          + 3*(CP0 - C0)
     *        0 = (C1 - CP1 - CP1 - CP1 + CP0 + CP0 + CP0 - C0)t^2
     *          + 2*(CP1 - CP0 - CP0 + C0)t
     *          + (CP0 - C0)
     *        0 = (C1 - CP1 + CP0 - CP1 + CP0 - CP1 + CP0 - C0)t^2
     *          + 2*(CP1 - CP0 - CP0 + C0)t
     *          + (CP0 - C0)
     *        0 = ((C1 - CP1) - (CP1 - CP0) - (CP1 - CP0) + (CP0 - C0))t^2
     *          + 2*((CP1 - CP0) - (CP0 - C0))t
     *          + (CP0 - C0)
     * Note that this method will return 0 if the equation is a line,
     * which is either always horizontal or never horizontal.
     * Completely horizontal curves need to be eliminated by other
     * means outside of this method.
     */
    public static function getHorizontalParams(c0:Number, cp0:Number, cp1:Number, c1:Number, ret:Vector.<Number>):int {
        if(c0 <= cp0 && cp0 <= cp1 && cp1 <= c1)
            return 0;

        c1 -= cp1;
        cp1 -= cp0;
        cp0 -= c0;
        ret[0] = cp0;
        ret[1] = (cp1 - cp0) * 2;
        ret[2] = (c1 - cp1 - cp1 + cp0);

        var numRoots:int = QuadCurve2D.solveQuadratic(ret, ret);
        var j:int = 0;
        for(var i:int = 0; i < numRoots; i++) {
            var t:Number = ret[i];
            // No splits at t==0 and t==1
            if(t > 0 && t < 1) {
                if(j < i) {
                    ret[j] = t;
                }
                j++;
            }
        }

        return j;
    }

    /*
     * Split the cubic Bezier stored at coords[pos...pos+7] representing
     * the parametric range [0..1] into two subcurves representing the
     * parametric subranges [0..t] and [t..1].  Store the results back
     * into the array at coords[pos...pos+7] and coords[pos+6...pos+13].
     */
    public static function split(coords:Vector.<Point2D>, pos:int, t:Number):void {
        var x0:Number, y0:Number, cx0:Number, cy0:Number, cx1:Number, cy1:Number, x1:Number, y1:Number;

        coords[pos + 6].x = x1 = coords[pos + 3].x;
        coords[pos + 6].y = y1 = coords[pos + 3].y;
        cx1 = coords[pos + 2].x;
        cy1 = coords[pos + 2].y;
        x1 = cx1 + (x1 - cx1) * t;
        y1 = cy1 + (y1 - cy1) * t;
        x0 = coords[pos + 0].x;
        y0 = coords[pos + 0].y;
        cx0 = coords[pos + 1].x;
        cy0 = coords[pos + 1].y;
        x0 = x0 + (cx0 - x0) * t;
        y0 = y0 + (cy0 - y0) * t;
        cx0 = cx0 + (cx1 - cx0) * t;
        cy0 = cy0 + (cy1 - cy0) * t;
        cx1 = cx0 + (x1 - cx0) * t;
        cy1 = cy0 + (y1 - cy0) * t;
        cx0 = x0 + (cx0 - x0) * t;
        cy0 = y0 + (cy0 - y0) * t;
        coords[pos + 1].x = x0;
        coords[pos + 1].y = y0;
        coords[pos + 2].x = cx0;
        coords[pos + 2].y = cy0;
        coords[pos + 3].x = cx0 + (cx1 - cx0) * t;
        coords[pos + 3].y = cy0 + (cy1 - cy0) * t;
        coords[pos + 4].x = cx1;
        coords[pos + 4].y = cy1;
        coords[pos + 5].x = x1;
        coords[pos + 5].y = y1;
    }

    public function Order3(x0:Number, y0:Number, cx0:Number, cy0:Number, cx1:Number, cy1:Number, x1:Number, y1:Number, direction:int) {
        super(direction);
        // REMIND: Better accuracy in the root finding methods would
        //  ensure that cys are in range.  As it stands, they are never
        //  more than "1 mantissa bit" out of range...
        if(cy0 < y0) cy0 = y0;
        if(cy1 > y1) cy1 = y1;
        this.x0 = x0;
        this.y0 = y0;
        this.cx0 = cx0;
        this.cy0 = cy0;
        this.cx1 = cx1;
        this.cy1 = cy1;
        this.x1 = x1;
        this.y1 = y1;
        xmin = Math.min(Math.min(x0, x1), Math.min(cx0, cx1));
        xmax = Math.max(Math.max(x0, x1), Math.max(cx0, cx1));
        xcoeff0 = x0;
        xcoeff1 = (cx0 - x0) * 3.0;
        xcoeff2 = (cx1 - cx0 - cx0 + x0) * 3.0;
        xcoeff3 = x1 - (cx1 - cx0) * 3.0 - x0;
        ycoeff0 = y0;
        ycoeff1 = (cy0 - y0) * 3.0;
        ycoeff2 = (cy1 - cy0 - cy0 + y0) * 3.0;
        ycoeff3 = y1 - (cy1 - cy0) * 3.0 - y0;
        YforT1 = YforT2 = YforT3 = y0;
    }

    override public function getOrder():int { return 3; }

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

    public function getCX0():Number {
        return (direction == INCREASING) ? cx0 : cx1;
    }

    public function getCY0():Number {
        return (direction == INCREASING) ? cy0 : cy1;
    }

    public function getCX1():Number {
        return (direction == DECREASING) ? cx0 : cx1;
    }

    public function getCY1():Number {
        return (direction == DECREASING) ? cy0 : cy1;
    }

    override public function getX1():Number {
        return (direction == DECREASING) ? x0 : x1;
    }

    override public function getY1():Number {
        return (direction == DECREASING) ? y0 : y1;
    }

    private var TforY1:Number;
    private var YforT1:Number;
    private var TforY2:Number;
    private var YforT2:Number;
    private var TforY3:Number;
    private var YforT3:Number;

    /*
     * Solve the cubic whose coefficients are in the a,b,c,d fields and
     * return the first root in the range [0, 1].
     * The cubic solved is represented by the equation:
     *     x^3 + (ycoeff2)x^2 + (ycoeff1)x + (ycoeff0) = y
     * @return the first valid root (in the range [0, 1])
     */
    override public function TforY(y:Number):Number {
        if(y <= y0) return 0;
        if(y >= y1) return 1;
        if(y == YforT1) return TforY1;
        if(y == YforT2) return TforY2;
        if(y == YforT3) return TforY3;

        // From Numerical Recipes, 5.6, Quadratic and Cubic Equations
        if(ycoeff3 == 0.0) {
            // The cubic degenerated to quadratic (or line or ...).
            return Order2.TforY(y, ycoeff0, ycoeff1, ycoeff2);
        }

        var a:Number = ycoeff2 / ycoeff3;
        var b:Number = ycoeff1 / ycoeff3;
        var c:Number = (ycoeff0 - y) / ycoeff3;
        var roots:int = 0;
        var Q:Number = (a * a - 3.0 * b) / 9.0;
        var R:Number = (2.0 * a * a * a - 9.0 * a * b + 27.0 * c) / 54.0;
        var R2:Number = R * R;
        var Q3:Number = Q * Q * Q;
        var a_3:Number = a / 3.0;
        var t:Number;

        if(R2 < Q3) {
            var theta:Number = Math.acos(R / Math.sqrt(Q3));
            Q = -2.0 * Math.sqrt(Q);
            t = refine(a, b, c, y, Q * Math.cos(theta / 3.0) - a_3);

            if(t < 0)
                t = refine(a, b, c, y, Q * Math.cos((theta + Math.PI * 2.0) / 3.0) - a_3);

            if(t < 0)
                t = refine(a, b, c, y, Q * Math.cos((theta - Math.PI * 2.0) / 3.0) - a_3);
        }
        else {
            var neg:Boolean = (R < 0.0);
            var S:Number = Math.sqrt(R2 - Q3);
            if(neg)
                R = -R;

            var A:Number = Math.pow(R + S, 1.0 / 3.0);

            if(!neg)
                A = -A;

            var B:Number = (A == 0.0) ? 0.0 : (Q / A);
            t = refine(a, b, c, y, (A + B) - a_3);
        }

        if(t < 0) {
            //throw new InternalError("bad t");
            var t0:Number = 0;
            var t1:Number = 1;

            while(true) {
                t = (t0 + t1) / 2;

                if(t == t0 || t == t1)
                    break;

                var yt:Number = YforT(t);

                if(yt < y)
                    t0 = t;
                else if(yt > y)
                    t1 = t;
                else
                    break;
            }
        }

        if(t >= 0) {
            TforY3 = TforY2;
            YforT3 = YforT2;
            TforY2 = TforY1;
            YforT2 = YforT1;
            TforY1 = t;
            YforT1 = y;
        }

        return t;
    }

    public function refine(a:Number, b:Number, c:Number, target:Number, t:Number):Number {
        if(t < -0.1 || t > 1.1)
            return -1;

        var y:Number = YforT(t);
        var t0:Number, t1:Number;

        if(y < target) {
            t0 = t;
            t1 = 1;
        }
        else {
            t0 = 0;
            t1 = t;
        }

        var origt:Number = t;
        var origy:Number = y;
        var useslope:Boolean = true;

        var t2:Number;

        while(y != target) {
            if(!useslope) {
                t2 = (t0 + t1) / 2;
                if(t2 == t0 || t2 == t1) {
                    break;
                }
                t = t2;
            }
            else {
                var slope:Number = dYforT(t, 1);
                if(slope == 0) {
                    useslope = false;
                    continue;
                }
                t2 = t + ((target - y) / slope);
                if(t2 == t || t2 <= t0 || t2 >= t1) {
                    useslope = false;
                    continue;
                }
                t = t2;
            }
            y = YforT(t);
            if(y < target) {
                t0 = t;
            }
            else if(y > target) {
                t1 = t;
            }
            else {
                break;
            }
        }
        var verbose:Boolean = false;
        if(false && t >= 0 && t <= 1) {
            y = YforT(t);
            var tdiff:Number = diffbits(t, origt);
            var ydiff:Number = diffbits(y, origy);
            var yerr:Number = diffbits(y, target);
            if(yerr > 0 || (verbose && tdiff > 0)) {
                var tlow:Number = prev(t);
                var ylow:Number = YforT(tlow);
                var thi:Number = next(t);
                var yhi:Number = YforT(thi);
            }
        }

        return (t > 1) ? -1 : t;
    }

    override public function XforY(y:Number):Number {
        if(y <= y0)
            return x0;

        if(y >= y1)
            return x1;

        return XforT(TforY(y));
    }

    override public function XforT(t:Number):Number {
        return (((xcoeff3 * t) + xcoeff2) * t + xcoeff1) * t + xcoeff0;
    }

    override public function YforT(t:Number):Number {
        return (((ycoeff3 * t) + ycoeff2) * t + ycoeff1) * t + ycoeff0;
    }

    override public function dXforT(t:Number, deriv:int):Number {
        switch(deriv) {
            case 0:
                return (((xcoeff3 * t) + xcoeff2) * t + xcoeff1) * t + xcoeff0;
            case 1:
                return ((3 * xcoeff3 * t) + 2 * xcoeff2) * t + xcoeff1;
            case 2:
                return (6 * xcoeff3 * t) + 2 * xcoeff2;
            case 3:
                return 6 * xcoeff3;
            default:
                return 0;
        }
    }

    override public function dYforT(t:Number, deriv:int):Number {
        switch(deriv) {
            case 0:
                return (((ycoeff3 * t) + ycoeff2) * t + ycoeff1) * t + ycoeff0;
            case 1:
                return ((3 * ycoeff3 * t) + 2 * ycoeff2) * t + ycoeff1;
            case 2:
                return (6 * ycoeff3 * t) + 2 * ycoeff2;
            case 3:
                return 6 * ycoeff3;
            default:
                return 0;
        }
    }

    override public function nextVertical(t0:Number, t1:Number):Number {
        //var eqn:Vector.<Number> = new <Number>[xcoeff1, 2 * xcoeff2, 3 * xcoeff3];
        _tmp[0] = xcoeff1; _tmp[1] = 2 * xcoeff2; _tmp[2] = 3 * xcoeff3;

        var numroots:int = QuadCurve2D.solveQuadratic(_tmp, _tmp);

        for(var i:int = 0; i < numroots; i++)
            if(_tmp[i] > t0 && _tmp[i] < t1)
                t1 = _tmp[i];

        return t1;
    }

    override public function enlarge(r:Rectangle2D):void {
        r.add(x0, y0);

        //var eqn:Vector.<Number> = new <Number>[xcoeff1, 2 * xcoeff2, 3 * xcoeff3];
        _tmp[0] = xcoeff1; _tmp[1] = 2 * xcoeff2; _tmp[2] = 3 * xcoeff3;

        var numroots:int = QuadCurve2D.solveQuadratic(_tmp, _tmp);

        for(var i:int = 0; i < numroots; i++) {
            var t:Number = _tmp[i];

            if(t > 0 && t < 1)
                r.add(XforT(t), YforT(t));
        }

        r.add(x1, y1);
    }

    override public function getSubCurveDir(ystart:Number, yend:Number, dir:int):Curve {
        if(ystart <= y0 && yend >= y1) {
            return getWithDirection(dir);
        }
        var eqn:Vector.<Point2D> = new Vector.<Point2D>(7, true);
        eqn[0] = new Point2D(); eqn[1] = new Point2D(); eqn[2] = new Point2D();
        eqn[3] = new Point2D(); eqn[4] = new Point2D(); eqn[5] = new Point2D();
        eqn[6] = new Point2D();

        var t0:Number, t1:Number;

        t0 = TforY(ystart);
        t1 = TforY(yend);

        eqn[0].x = x0;
        eqn[0].y = y0;
        eqn[1].x = cx0;
        eqn[1].y = cy0;
        eqn[2].x = cx1;
        eqn[2].y = cy1;
        eqn[3].x = x1;
        eqn[3].y = y1;

        if(t0 > t1) {
            /* This happens in only rare cases where ystart is
             * very near yend and solving for the yend root ends
             * up stepping slightly lower in t than solving for
             * the ystart root.
             * Ideally we might want to skip this tiny little
             * segment and just fudge the surrounding coordinates
             * to bridge the gap left behind, but there is no way
             * to do that from here.  Higher levels could
             * potentially eliminate these tiny "fixup" segments,
             * but not without a lot of extra work on the code that
             * coalesces chains of curves into subpaths.  The
             * simplest solution for now is to just reorder the t
             * values and chop out a miniscule curve piece.
             */
            var t:Number = t0;
            t0 = t1;
            t1 = t;
        }

        if(t1 < 1)
            split(eqn, 0, t1);

        var i:int;

        if(t0 <= 0) {
            i = 0;
        }
        else {
            split(eqn, 0, t0 / t1);
            i = 3;
        }

        return new Order3(eqn[i + 0].x, ystart, eqn[i + 1].x, eqn[i + 1].y, eqn[i + 2].x, eqn[i + 2].y, eqn[i + 3].x, yend, dir);
    }

    override public function getReversedCurve():Curve {
        return new Order3(x0, y0, cx0, cy0, cx1, cy1, x1, y1, -direction);
    }

    override public function getSegment(coords:Vector.<Point2D>):SegmentType {
        if(direction == INCREASING) {
            coords[0].x = cx0;
            coords[0].y = cy0;
            coords[1].x = cx1;
            coords[1].y = cy1;
            coords[2].x = x1;
            coords[2].y = y1;
        }
        else {
            coords[0].x = cx1;
            coords[0].y = cy1;
            coords[1].x = cx0;
            coords[1].y = cy0;
            coords[2].x = x0;
            coords[2].y = y0;
        }
        return SegmentType.CubicTo;
    }

    override public function controlPointString():String {
        return (("(" + round(getCX0()) + ", " + round(getCY0()) + "), ") +
                ("(" + round(getCX1()) + ", " + round(getCY1()) + "), "));
    }
}
}
