/**
 * User: booster
 * Date: 15/05/14
 * Time: 15:04
 */
package medkit.geom.shapes.curve {
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.crossings.Crossings;
import medkit.geom.shapes.enum.SegmentType;

public class Order0 extends Curve {
    private var x:Number;
    private var y:Number;

    public function Order0(x:Number, y:Number) {
        super(INCREASING);
        this.x = x;
        this.y = y;
    }

    override public function getOrder():int { return 0; }

    override public function getXTop():Number { return x; }

    override public function getYTop():Number { return y; }

    override public function getXBot():Number { return x; }

    override public function getYBot():Number { return y; }

    override public function getXMin():Number { return x; }

    override public function getXMax():Number { return x; }

    override public function getX0():Number { return x; }

    override public function getY0():Number { return y; }

    override public function getX1():Number { return x; }

    override public function getY1():Number { return y; }

    override public function XforY(y:Number):Number { return y; }

    override public function TforY(y:Number):Number { return 0; }

    override public function XforT(t:Number):Number { return x; }

    override public function YforT(t:Number):Number { return y; }

    override public function dXforT(t:Number, deriv:int):Number { return 0; }

    override public function dYforT(t:Number, deriv:int):Number { return 0; }

    override public function nextVertical(t0:Number, t1:Number):Number { return t1; }

    override public function crossingsFor(x:Number, y:Number):int { return 0; }

    override public function accumulateCrossings(c:Crossings):Boolean {
        return (x > c.getXLo() &&
                x < c.getXHi() &&
                y > c.getYLo() &&
                y < c.getYHi());
    }

    override public function enlarge(r:Rectangle2D):void { r.add(x, y); }

    override public function getSubCurveDir(ystart:Number, yend:Number, dir:int):Curve { return this; }

    override public function getReversedCurve():Curve { return this; }

    override public function getSegment(coords:Vector.<Point2D>):SegmentType {
        coords[0].x = x;
        coords[0].y = y;

        return SegmentType.MoveTo;
    }
}
}
