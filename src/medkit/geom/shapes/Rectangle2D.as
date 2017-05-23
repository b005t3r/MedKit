/**
 * User: booster
 * Date: 14/05/14
 * Time: 11:13
 */
package medkit.geom.shapes {
import flash.geom.Matrix;
import flash.geom.Rectangle;

import medkit.collection.spatial.Spatial;
import medkit.object.Hashable;

public class Rectangle2D extends Rectangle implements Shape2D, Hashable, Spatial {
    /** The bitmask that indicates that a point lies to the left of this <code>Rectangle2D</code>. */
    public static const OUT_LEFT:int = 1;

    /** The bitmask that indicates that a point lies above this <code>Rectangle2D</code>. */
    public static const OUT_TOP:int = 2;

    /** The bitmask that indicates that a point lies to the right of this <code>Rectangle2D</code>. */
    public static const OUT_RIGHT:int = 4;

    /** The bitmask that indicates that a point lies below this <code>Rectangle2D</code>. */
    public static const OUT_BOTTOM:int = 8;

    private static const _tempRect:Rectangle2D = new Rectangle2D();

    private static var rectanglePool:Vector.<Rectangle2D> = new <Rectangle2D>[];

    /** Retrieves a Rectangle2D instance from the pool. */
    public static function getRectangle(x:Number = 0, y:Number = 0, w:Number = 0, h:Number = 0):Rectangle2D {
        if (rectanglePool.length == 0)
            return new Rectangle2D(x, y, w, h);

        var rectangle:Rectangle2D = rectanglePool.pop();
        rectangle.x = x; rectangle.y = y; rectangle.width =  w; rectangle.height = h;
        return rectangle;
    }

    /** Stores a Rectangle2D instance in the pool.
     *  Don't keep any references to the object after moving it to the pool! */
    public static function putRectangle(rectangle:Rectangle2D):void {
        if (rectangle == null)
            throw new ArgumentError("cannot put back null");

        rectanglePool[rectanglePool.length] = rectangle;
    }

    public function Rectangle2D(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) {
        super(x, y, width, height);
    }

    public function getBounds(result:Rectangle2D = null):Rectangle2D {
        if(result == null) result = new Rectangle2D();

        result.x = x; result.y = y;
        result.width = width; result.height = height;

        return result;
    }

    public function intersectsRect(x:Number, y:Number, w:Number, h:Number):Boolean {
        _tempRect.setTo(x, y, w, h);

        return intersects(_tempRect);
    }

    public function intersectsRectangle2D(rect:Rectangle2D):Boolean {
        return intersects(rect);
    }

    public function intersectsLine(x1:Number, y1:Number, x2:Number, y2:Number):Boolean {
        var out1:int, out2:int;

        if((out2 = outCode(x2, y2)) == 0) {
            return true;
        }

        while((out1 = outCode(x1, y1)) != 0) {
            if((out1 & out2) != 0)
                return false;

            if((out1 & (OUT_LEFT | OUT_RIGHT)) != 0) {
                var x:Number = this.x;

                if((out1 & OUT_RIGHT) != 0)
                    x += this.width;

                y1 = y1 + (x - x1) * (y2 - y1) / (x2 - x1);
                x1 = x;
            }
            else {
                var y:Number = this.y;

                if((out1 & OUT_BOTTOM) != 0)
                    y += this.height;

                x1 = x1 + (y - y1) * (x2 - x1) / (y2 - y1);
                y1 = y;
            }
        }

        return true;
    }

    public function intersectsLine2D(line:Line2D):Boolean {
        return intersectsLine(line.x1, line.y1, line.x2, line.y2);
    }

    public function containsPoint2D(point:Point2D):Boolean {
        return containsPoint(point);
    }

    public function containsRectangle2D(rect:Rectangle2D):Boolean {
        return containsRect(rect);
    }

    public function add(newX:Number, newY:Number):void {
        var x1:Number = x < newX ? x : newX;
        var x2:Number = x + width > newX ? x + width : newX;
        var y1:Number = y < newY ? y : newY;
        var y2:Number = y + height > newY ? y + height : newY;

        setTo(x1, y1, x2 - x1, y2 - y1);
    }

    public function addPoint2D(point:Point2D):void {
        add(point.x, point.y);
    }

    public function getPathIterator(transformMatrix:Matrix = null, flatness:Number = 0):PathIterator {
        return new RectIterator(this, transformMatrix);
    }

    override public function clone():Rectangle {
        return new Rectangle2D(x, y, width, height);
    }

    public function hashCode():int {
        return (height << 24) | (width << 16) | (y << 8) | x;
    }

    public function get indexCount():int { return 2; }
    public function minValue(index:int):Number { return index == 0 ? x : y; }
    public function maxValue(index:int):Number { return index == 0 ? x + width : y + height; }

    public function outCode(x:Number, y:Number):int {
        var out:int = 0;

        if (this.width <= 0)                out |= OUT_LEFT | OUT_RIGHT;
        else if (x < this.x)                out |= OUT_LEFT;
        else if (x > this.x + this.width)   out |= OUT_RIGHT;

        if (this.height <= 0)               out |= OUT_TOP | OUT_BOTTOM;
        else if (y < this.y)                out |= OUT_TOP;
        else if (y > this.y + this.height)  out |= OUT_BOTTOM;

        return out;
    }
}
}

import flash.geom.Matrix;

import medkit.geom.GeomUtil;
import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;
import medkit.geom.shapes.enum.SegmentType;
import medkit.geom.shapes.enum.WindingRule;

class RectIterator implements PathIterator {
    public var rect:Rectangle2D;
    public var matrix:Matrix;
    public var index:int;

    public function RectIterator(rect:Rectangle2D, matrix:Matrix = null) {
        this.rect   = rect;
        this.matrix = matrix;
        this.index  = 0;
    }

    public function getWindingRule():WindingRule { return WindingRule.NonZero; }

    public function isDone():Boolean {
        return index > 4;
    }

    public function next():void { ++index; }

    public function currentSegment(coords:Vector.<Point2D>):SegmentType {
        if (index > 4)
            throw new RangeError("rect iterator out of bounds");

        if (index == 4)
            return SegmentType.Close;

        coords[0].x = rect.x;
        coords[0].y = rect.y;

        if (index == 1 || index == 2)   coords[0].x += rect.width;
        if (index == 2 || index == 3)   coords[0].y += rect.height;

        if (matrix != null)
            GeomUtil.transformPoint2D(matrix, coords[0].x, coords[0].y, coords[0]);

        return index == 0 ? SegmentType.MoveTo : SegmentType.LineTo;
    }
}
