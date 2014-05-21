/**
 * User: booster
 * Date: 14/05/14
 * Time: 9:38
 */
package medkit.geom.shapes {
import flash.geom.Point;

import medkit.collection.spatial.Spatial;

import medkit.object.Hashable;

public class Point2D extends Point implements Hashable, Spatial {
    public function Point2D(x:Number = 0, y:Number = 0) {
        super(x, y);
    }

    public function distance(point:Point):Number {
        var dy:Number = point.y - y;
        var dx:Number = point.x - x;

        return Math.sqrt(dx * dx + dy * dy);
    }

    public function distanceSq(point:Point):Number {
        var dy:Number = point.y - y;
        var dx:Number = point.x - x;

        return dx * dx + dy * dy;
    }

    public function setLocation(point:Point2D):void {
        x = point.x;
        y = point.y;
    }

    public function hashCode():int {
        return ((y << 16) | x);
    }

    override public function clone():Point {
        return new Point2D(x, y);
    }

    public function get indexCount():int { return 2; }
    public function minValue(index:int):Number { return index == 0 ? x : y; }
    public function maxValue(index:int):Number { return index == 0 ? x : y; }
}
}