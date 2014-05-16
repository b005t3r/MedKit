/**
 * User: booster
 * Date: 15/05/14
 * Time: 15:22
 */
package medkit.geom.shapes.curve {
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.crossings.Crossings;
import medkit.geom.shapes.enum.SegmentType;

public class Order1 extends Curve {
    private var x0:Number;
    private var y0:Number;
    private var x1:Number;
    private var y1:Number;
    private var xmin:Number;
    private var xmax:Number;

    public function Order1(x0:Number, y0:Number, x1:Number, y1:Number, direction:int) {
        super(direction);
        this.x0 = x0;
        this.y0 = y0;
        this.x1 = x1;
        this.y1 = y1;
        if(x0 < x1) {
            this.xmin = x0;
            this.xmax = x1;
        }
        else {
            this.xmin = x1;
            this.xmax = x0;
        }
    }

    override public function getOrder():int {
        return 1;
    }

    override public function getXTop():Number {
        return x0;
    }

    override public function getYTop():Number {
        return y0;
    }

    override public function getXBot():Number {
        return x1;
    }

    override public function getYBot():Number {
        return y1;
    }

    override public function getXMin():Number {
        return xmin;
    }

    override public function getXMax():Number {
        return xmax;
    }

    override public function getX0():Number {
        return (direction == INCREASING) ? x0 : x1;
    }

    override public function getY0():Number {
        return (direction == INCREASING) ? y0 : y1;
    }

    override public function getX1():Number {
        return (direction == DECREASING) ? x0 : x1;
    }

    override public function getY1():Number {
        return (direction == DECREASING) ? y0 : y1;
    }

    override public function XforY(y:Number):Number {
        if(x0 == x1 || y <= y0) {
            return x0;
        }
        if(y >= y1) {
            return x1;
        }
        // assert(y0 != y1); /* No horizontal lines... */
        return (x0 + (y - y0) * (x1 - x0) / (y1 - y0));
    }

    override public function TforY(y:Number):Number {
        if(y <= y0) {
            return 0;
        }
        if(y >= y1) {
            return 1;
        }
        return (y - y0) / (y1 - y0);
    }

    override public function XforT(t:Number):Number {
        return x0 + t * (x1 - x0);
    }

    override public function YforT(t:Number):Number {
        return y0 + t * (y1 - y0);
    }

    override public function dXforT(t:Number, deriv:int):Number {
        switch(deriv) {
            case 0:
                return x0 + t * (x1 - x0);
            case 1:
                return (x1 - x0);
            default:
                return 0;
        }
    }

    override public function dYforT(t:Number, deriv:int):Number {
        switch(deriv) {
            case 0:
                return y0 + t * (y1 - y0);
            case 1:
                return (y1 - y0);
            default:
                return 0;
        }
    }

    override public function nextVertical(t0:Number, t1:Number):Number { return t1; }

    override public function accumulateCrossings(c:Crossings):Boolean {
        var xlo:Number = c.getXLo();
        var ylo:Number = c.getYLo();
        var xhi:Number = c.getXHi();
        var yhi:Number = c.getYHi();

        if(xmin >= xhi)
            return false;

        var xstart:Number, ystart:Number, xend:Number, yend:Number;

        if(y0 < ylo) {
            if(y1 <= ylo)
                return false;

            ystart = ylo;
            xstart = XforY(ylo);
        }
        else {
            if(y0 >= yhi)
                return false;

            ystart = y0;
            xstart = x0;
        }

        if(y1 > yhi) {
            yend = yhi;
            xend = XforY(yhi);
        }
        else {
            yend = y1;
            xend = x1;
        }

        if(xstart >= xhi && xend >= xhi)
            return false;

        if(xstart > xlo || xend > xlo)
            return true;

        c.record(ystart, yend, direction);

        return false;
    }

    override public function enlarge(r:Rectangle2D):void {
        r.add(x0, y0);
        r.add(x1, y1);
    }

    override public function getSubCurveDir(ystart:Number, yend:Number, dir:int):Curve {
        if(ystart == y0 && yend == y1)
            return getWithDirection(dir);

        if(x0 == x1)
            return new Order1(x0, ystart, x1, yend, dir);

        var num:Number = x0 - x1;
        var denom:Number = y0 - y1;
        var xstart:Number = (x0 + (ystart - y0) * num / denom);
        var xend:Number = (x0 + (yend - y0) * num / denom);

        return new Order1(xstart, ystart, xend, yend, dir);
    }

    override public function getReversedCurve():Curve {
        return new Order1(x0, y0, x1, y1, -direction);
    }

    override public function compareTo(other:Curve, yrange:Vector.<Number>):int {
        var c1:Order1 = other as Order1;

        if(c1 == null)
            return super.compareTo(other, yrange);

        if(yrange[1] <= yrange[0])
            throw new Error("yrange already screwed up...");

        var tmp:Number = yrange[1] < y1 ? yrange[1] : y1;
        yrange[1] = tmp < c1.y1 ? tmp : c1.y1;

        if(yrange[1] <= yrange[0])
            throw new Error("backstepping from " + yrange[0] + " to " + yrange[1]);

        if(xmax <= c1.xmin)
            return (xmin == c1.xmax) ? 0 : -1;

        if(xmin >= c1.xmax)
            return 1;

        /*
         * If "this" is curve A and "other" is curve B, then...
         * xA(y) = x0A + (y - y0A) (x1A - x0A) / (y1A - y0A)
         * xB(y) = x0B + (y - y0B) (x1B - x0B) / (y1B - y0B)
         * xA(y) == xB(y)
         * x0A + (y - y0A) (x1A - x0A) / (y1A - y0A)
         *    == x0B + (y - y0B) (x1B - x0B) / (y1B - y0B)
         * 0 == x0A (y1A - y0A) (y1B - y0B) + (y - y0A) (x1A - x0A) (y1B - y0B)
         *    - x0B (y1A - y0A) (y1B - y0B) - (y - y0B) (x1B - x0B) (y1A - y0A)
         * 0 == (x0A - x0B) (y1A - y0A) (y1B - y0B)
         *    + (y - y0A) (x1A - x0A) (y1B - y0B)
         *    - (y - y0B) (x1B - x0B) (y1A - y0A)
         * If (dxA == x1A - x0A), etc...
         * 0 == (x0A - x0B) * dyA * dyB
         *    + (y - y0A) * dxA * dyB
         *    - (y - y0B) * dxB * dyA
         * 0 == (x0A - x0B) * dyA * dyB
         *    + y * dxA * dyB - y0A * dxA * dyB
         *    - y * dxB * dyA + y0B * dxB * dyA
         * 0 == (x0A - x0B) * dyA * dyB
         *    + y * dxA * dyB - y * dxB * dyA
         *    - y0A * dxA * dyB + y0B * dxB * dyA
         * 0 == (x0A - x0B) * dyA * dyB
         *    + y * (dxA * dyB - dxB * dyA)
         *    - y0A * dxA * dyB + y0B * dxB * dyA
         * y == ((x0A - x0B) * dyA * dyB
         *       - y0A * dxA * dyB + y0B * dxB * dyA)
         *    / (-(dxA * dyB - dxB * dyA))
         * y == ((x0A - x0B) * dyA * dyB
         *       - y0A * dxA * dyB + y0B * dxB * dyA)
         *    / (dxB * dyA - dxA * dyB)
         */
        var dxa:Number = x1 - x0;
        var dya:Number = y1 - y0;
        var dxb:Number = c1.x1 - c1.x0;
        var dyb:Number = c1.y1 - c1.y0;
        var denom:Number = dxb * dya - dxa * dyb;
        var y:Number;

        if(denom != 0) {
            var num:Number = ((x0 - c1.x0) * dya * dyb - y0 * dxa * dyb + c1.y0 * dxb * dya);
            y = num / denom;

            if(y <= yrange[0]) {
                // intersection is above us
                // Use bottom-most common y for comparison
                y = Math.min(y1, c1.y1);
            }
            else {
                // intersection is below the top of our range
                if(y < yrange[1]) {
                    // If intersection is in our range, adjust valid range
                    yrange[1] = y;
                }

                // Use top-most common y for comparison
                y = Math.max(y0, c1.y0);
            }
        }
        else {
            // lines are parallel, choose any common y for comparison
            // Note - prefer an endpoint for speed of calculating the X
            // (see shortcuts in Order1.XforY())
            y = Math.max(y0, c1.y0);
        }

        return orderof(XforY(y), c1.XforY(y));
    }

    override public function getSegment(coords:Vector.<Point2D>):SegmentType {
        if(direction == INCREASING) {
            coords[0].x = x1;
            coords[0].y = y1;
        }
        else {
            coords[0].x = x0;
            coords[0].y = y0;
        }

        return SegmentType.LineTo;
    }
}
}
