/**
 * User: booster
 * Date: 14/05/14
 * Time: 15:51
 */
package medkit.geom.shapes.crossings {
import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.curve.Curve;
import medkit.geom.shapes.enum.SegmentType;
import medkit.geom.shapes.enum.WindingRule;

public class Crossings {
    internal var limit:int = 0;
    internal var yranges:Vector.<Number> = new Vector.<Number>(10);

    internal var xlo:Number, ylo:Number, xhi:Number, yhi:Number;

    private var tmp:Vector.<Curve> = new <Curve>[];

    public function Crossings(xlo:Number, ylo:Number, xhi:Number, yhi:Number) {
        this.xlo = xlo;
        this.ylo = ylo;
        this.xhi = xhi;
        this.yhi = yhi;
    }

    public final function getXLo():Number {
        return xlo;
    }

    public final function getYLo():Number {
        return ylo;
    }

    public final function getXHi():Number {
        return xhi;
    }

    public final function getYHi():Number {
        return yhi;
    }

    public final function isEmpty():Boolean {
        return (limit == 0);
    }

    public function record(ystart:Number, yend:Number, direction:int):void { throw new Error("abstract method"); }

    public function covers(ystart:Number, yend:Number):Boolean { throw new Error("abstract method"); }

    /*
     public function print():void{
     System.out.println("Crossings [");
     System.out.println("  bounds = ["+ylo+", "+yhi+"]");
     for (var i:int= 0; i < limit; i += 2) {
     System.out.println("  ["+yranges[i]+", "+yranges[i+1]+"]");
     }
     System.out.println("]");
     }
     */

    public static function findCrossings(curves:Vector.<Curve>, xlo:Number, ylo:Number, xhi:Number, yhi:Number):Crossings {
        var cross:Crossings = new EvenOdd(xlo, ylo, xhi, yhi);

        var count:int = curves.length;
        for(var i:int = 0; i < count; ++i) {
            var c:Curve = curves[i];

            if(c.accumulateCrossings(cross))
                return null;
        }

        return cross;
    }

    public static function findCrossingsPathIt(pi:PathIterator, xlo:Number, ylo:Number, xhi:Number, yhi:Number):Crossings {
        var cross:Crossings;

        if(pi.getWindingRule() == WindingRule.EvenOdd)
            cross = new EvenOdd(xlo, ylo, xhi, yhi);
        else
            cross = new NonZero(xlo, ylo, xhi, yhi);

        // coords array is big enough for holding:
        //     coordinates returned from currentSegment (6)
        //     OR
        //         two subdivided quadratic curves (2+4+4=10)
        //         AND
        //             0-1 horizontal splitting parameters
        //             OR
        //             2 parametric equation derivative coefficients
        //     OR
        //         three subdivided cubic curves (2+6+6+6=20)
        //         AND
        //             0-2 horizontal splitting parameters
        //             OR
        //             3 parametric equation derivative coefficients
        var coords:Vector.<Point2D> = new Vector.<Point2D>(3, true);
        var movx:Number = 0;
        var movy:Number = 0;
        var curx:Number = 0;
        var cury:Number = 0;
        var newx:Number, newy:Number;

        while(!pi.isDone()) {
            var segType:SegmentType = pi.currentSegment(coords);

            switch(segType) {
                case SegmentType.MoveTo:
                    if(movy != cury && cross.accumulateLine(curx, cury, movx, movy))
                        return null;

                    movx = curx = coords[0].x;
                    movy = cury = coords[0].y;
                    break;

                case SegmentType.LineTo:
                    newx = coords[0].x;
                    newy = coords[0].y;

                    if(cross.accumulateLine(curx, cury, newx, newy))
                        return null;

                    curx = newx;
                    cury = newy;
                    break;

                case SegmentType.QuadTo:
                    newx = coords[1].x;
                    newy = coords[1].y;

                    if(cross.accumulateQuad(curx, cury, coords))
                        return null;

                    curx = newx;
                    cury = newy;
                    break;

                case SegmentType.CubicTo:
                    newx = coords[2].x;
                    newy = coords[2].y;

                    if(cross.accumulateCubic(curx, cury, coords))
                        return null;

                    curx = newx;
                    cury = newy;
                    break;

                case SegmentType.Close:
                    if(movy != cury && cross.accumulateLine(curx, cury, movx, movy))
                        return null;

                    curx = movx;
                    cury = movy;
                    break;
            }

            pi.next();
        }

        if(movy != cury) {
            if(cross.accumulateLine(curx, cury, movx, movy))
                return null;
        }

        return cross;
    }

    public function accumulateLine(x0:Number, y0:Number, x1:Number, y1:Number):Boolean {
        if(y0 <= y1)
            return accumulateLineDir(x0, y0, x1, y1, 1);
        else
            return accumulateLineDir(x1, y1, x0, y0, -1);
    }

    public function accumulateLineDir(x0:Number, y0:Number, x1:Number, y1:Number, direction:int):Boolean {
        if(yhi <= y0 || ylo >= y1)
            return false;

        if(x0 >= xhi && x1 >= xhi)
            return false;

        if(y0 == y1)
            return (x0 >= xlo || x1 >= xlo);

        var xstart:Number, ystart:Number, xend:Number, yend:Number;
        var dx:Number = (x1 - x0);
        var dy:Number = (y1 - y0);

        if(y0 < ylo) {
            xstart = x0 + (ylo - y0) * dx / dy;
            ystart = ylo;
        }
        else {
            xstart = x0;
            ystart = y0;
        }

        if(yhi < y1) {
            xend = x0 + (yhi - y0) * dx / dy;
            yend = yhi;
        }
        else {
            xend = x1;
            yend = y1;
        }

        if(xstart >= xhi && xend >= xhi)
            return false;

        if(xstart > xlo || xend > xlo)
            return true;

        record(ystart, yend, direction);

        return false;
    }

    public function accumulateQuad(x0:Number, y0:Number, coords:Vector.<Point2D>):Boolean {

        if(y0 < ylo && coords[0].y < ylo && coords[1].y < ylo)
            return false;

        if(y0 > yhi && coords[0].y > yhi && coords[1].y > yhi)
            return false;

        if(x0 > xhi && coords[0].x > xhi && coords[1].x > xhi)
            return false;

        if(x0 < xlo && coords[0].x < xlo && coords[1].x < xlo) {
            if(y0 < coords[1].y)
                record(y0 > ylo ? y0 : ylo, coords[1].y < yhi ? coords[1].y : yhi, 1);
            else if(y0 > coords[1].y)
                record(coords[1].y > ylo ? coords[1].y : ylo, y0 < yhi ? y0 : yhi, -1);

            return false;
        }

        Curve.insertQuad(tmp, x0, y0, coords);

        var count:int = tmp.length;
        for(var i:int = 0; i < count; ++i) {
            var c:Curve = tmp[i];
            if(c.accumulateCrossings(this))
                return true;
        }

        tmp.length = 0;

        return false;
    }

    public function accumulateCubic(x0:Number, y0:Number, coords:Vector.<Point2D>):Boolean {
        if(y0 < ylo && coords[0].y < ylo && coords[1].y < ylo && coords[2].y < ylo)
            return false;

        if(y0 > yhi && coords[0].y > yhi && coords[1].y > yhi && coords[2].y > yhi)
            return false;

        if(x0 > xhi && coords[0].x > xhi && coords[1].x > xhi && coords[2].x > xhi)
            return false;

        if(x0 < xlo && coords[0].x < xlo && coords[1].x < xlo && coords[2].x < xlo) {
            if(y0 <= coords[2].y)
                record(y0 > ylo ? y0 : ylo, coords[2].y < yhi ? coords[2].y : yhi, 1);
            else
                record(coords[2].y > ylo ? coords[2].y : ylo, y0 < yhi ? y0 : yhi, -1);

            return false;
        }

        Curve.insertCubic(tmp, x0, y0, coords);

        var count:int = tmp.length;
        for(var i:int = 0; i < count; ++i) {
            var c:Curve = tmp[i];
            if(c.accumulateCrossings(this))
                return true;
        }

        tmp.length = 0;

        return false;
    }
}
}
