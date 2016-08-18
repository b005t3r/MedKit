/**
 * User: booster
 * Date: 07/02/14
 * Time: 8:54
 */
package medkit.geom {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Rectangle2D;

public class GeomUtil {
    public static function distanceBetweenPoints(x1:Number, y1:Number, x2:Number, y2:Number):Number {
        var dy:Number = y2 - y1;
        var dx:Number = x2 - x1;

        return Math.sqrt(dx * dx + dy * dy);
    }

    public static function angleBetweenPoints(x1:Number, y1:Number, x2:Number, y2:Number):Number {
        var dy:Number = y2 - y1;
        var dx:Number = x2 - x1;

        return (Math.atan2(dx, -dy) + 2 * Math.PI) % (2 * Math.PI);
    }

    public static function normalizeGlobalAngle(angle:Number):Number {
        angle = angle % (2 * Math.PI);

        return angle >= 0 ? angle : angle + 2 * Math.PI;
    }

    public static function normalizeLocalAngle(angle:Number):Number {
        angle = angle % (2 * Math.PI);

        return angle > Math.PI
            ? angle - Math.PI
            : angle < -Math.PI
                ? angle + Math.PI
                : angle
            ;
    }

    public static function projectPoint(x:Number, y:Number, angle:Number, distance:Number, result:Point2D = null):Point2D {
        if(result == null) result = new Point2D();

        result.setTo(
            (x + Math.sin(angle) * distance),
            (y - Math.cos(angle) * distance)    // minus when Y-Axis is going down, plus when it's going up
        );

        return result;
    }

    public static function linesIntersection(firstLine:Vector.<Point>, secondLine:Vector.<Point>, intersectionPoint:Point = null):Boolean {
        var p1:Point = firstLine[0],
            p2:Point = firstLine[1],
            p3:Point = secondLine[0],
            p4:Point = secondLine[1];

        // store the values for fast access and easy
        // equations-to-code conversion
        var x1:Number = p1.x, x2:Number = p2.x, x3:Number = p3.x, x4:Number = p4.x,
            y1:Number = p1.y, y2:Number = p2.y, y3:Number = p3.y, y4:Number = p4.y;

        var A1:Number = y2 - y1;
        var B1:Number = x1 - x2;
        var C1:Number = (A1 * x1) + (B1 * y1);

        var A2:Number = y4 - y3;
        var B2:Number = x3 - x4;
        var C2:Number = A2 * x3 + B2 * y3;

        var det:Number = A1 * B2 - A2 * B1;

        if(det == 0)
            return false;

        if(intersectionPoint != null)
            intersectionPoint.setTo((B2 * C1 - B1 * C2) / det, (A1 * C2 - A2 * C1) / det);

        return true;
    }

    public static function circlesIntersection(firstCircle:Point, firstRadius:Number, secondCircle:Point, secondRadius:Number):Vector.<Point> {
        var distance:Number = distanceBetweenPoints(firstCircle.x, firstCircle.y, secondCircle.x, secondCircle.y);

        // no intersection
        if(distance > firstRadius + secondRadius
               || distance < Math.abs(firstRadius - secondRadius)
            || distance == 0)
            return new <Point>[];

        // single intersection point
        if(distance == firstRadius + secondRadius) {
            var angle:Number = angleBetweenPoints(firstCircle.x, firstCircle.y, secondCircle.x, secondCircle.y);
            var point:Point = projectPoint(firstCircle.x, firstCircle.y, angle, firstRadius);

            return new <Point>[point];
        }

        // two intersection points
        var ang:Number = angleBetweenPoints(firstCircle.x, firstCircle.y, secondCircle.x, secondCircle.y);
        var a:Number = (firstRadius * firstRadius - secondRadius * secondRadius + distance * distance) / (2 * distance);
        var p:Point = projectPoint(firstCircle.x, firstCircle.y, ang, a);
        var h:Number = Math.sqrt(firstRadius * firstRadius - a * a);

        var firstIntersection:Point = new Point(
            p.x + h * (secondCircle.y - firstCircle.y) / distance,
            p.y - h * (secondCircle.x - firstCircle.x) / distance
        );

        var secondIntersection:Point = new Point(
            p.x - h * (secondCircle.y - firstCircle.y) / distance,
            p.y + h * (secondCircle.x - firstCircle.x) / distance
        );

        return new <Point>[firstIntersection, secondIntersection];
    }

    public static function rectangleIntersection(rect:Rectangle, otherRect:Rectangle, resultRect:Rectangle = null):Rectangle {
        var x1:Number = rect.left > otherRect.left ? rect.left : otherRect.left,
            y1:Number = rect.top > otherRect.top ? rect.top : otherRect.top,
            x2:Number = rect.right < otherRect.right ? rect.right : otherRect.right,
            y2:Number = rect.bottom < otherRect.bottom ? rect.bottom : otherRect.bottom
        ;

        var width:Number = x2 - x1;

        if(width < 0)
            return null;

        var height:Number = y2 - y1;

        if(height < 0)
            return null;

        if(resultRect == null)
            resultRect = new Rectangle();

        resultRect.setTo(x1, y1, width, height);

        return resultRect;
    }

    public static function rectangleUnion(rect:Rectangle, otherRect:Rectangle, resultRect:Rectangle = null):Rectangle {
        var x1:Number = Math.min(rect.left, otherRect.left),
            y1:Number = Math.min(rect.top, otherRect.top),
            x2:Number = Math.max(rect.right, otherRect.right),
            y2:Number = Math.max(rect.bottom, otherRect.bottom);

        var width:Number = Math.abs(x2 - x1);
        var height:Number = Math.abs(y2 - y1);

        if(resultRect == null)
            resultRect = new Rectangle();

        resultRect.setTo(x1 < x2 ? x1 : x2, y1 < y2 ? y1 : y2 , width, height);

        return resultRect;
    }

    /**
     * +-----.-----.-------------+
     * |     .     .             |
     * |  A  .  B  .      C      |
     * |     .     .             |
     * ......+-----+..............
     * |  D  |     |      E      |
     * ......+-----+..............
     * |     .     .             |
     * |  F  .  G  .      H      |
     * |     .     .             |
     * +-----.-----.-------------+
     * @param rect
     * @param otherRect
     * @param resultRects
     * @param tempRect
     * @return
     */
    public static function rectangleSubtraction(rect:Rectangle, otherRect:Rectangle, resultRects:Vector.<Rectangle> = null, tempRect:Rectangle = null):Vector.<Rectangle> {
        var intersection:Rectangle = rectangleIntersection(rect, otherRect, tempRect);

        // no intersection
        if(intersection == null || intersection.width == 0 || intersection.height == 0) {
            if(resultRects == null)
                resultRects = new <Rectangle>[];

            resultRects[0] = rect;

            return resultRects;
        }
        // zero-rectangle - whole rect is covered by otherRect
        else if(intersection.containsRect(rect)) {
            if(resultRects == null)
                resultRects = new <Rectangle>[];

            return resultRects;
        }

        var x:Number = rect.x, y:Number = rect.y, w:Number = rect.width, h:Number = rect.height;
        var ix:Number = intersection.x, iy:Number = intersection.y, iw:Number = intersection.width, ih:Number = intersection.height;

        if(resultRects == null)
            resultRects = new <Rectangle>[];

        if(x < ix && y < iy)
            resultRects[resultRects.length] = new Rectangle(x, y, ix - x, iy - y);

        if(y < iy)
            resultRects[resultRects.length] = new Rectangle(ix, y, iw, iy - y);

        if(x + w > ix + iw && y < iy)
            resultRects[resultRects.length] = new Rectangle(ix + iw, y, x + w - ix - iw, iy - y);

        if(x < ix)
            resultRects[resultRects.length] = new Rectangle(x, iy, ix - x, ih);

        if(x + w > ix + iw)
            resultRects[resultRects.length] = new Rectangle(ix + iw, iy, x + w - ix - iw, ih);

        if(x < ix && y + h > iy + ih)
            resultRects[resultRects.length] = new Rectangle(x, iy + ih, ix - x, y + h - iy - ih);

        if(y + h > iy + ih)
            resultRects[resultRects.length] = new Rectangle(ix, iy + ih, iw, y + h - iy - ih);

        if(x + w > ix + iw && y + h > iy + ih)
            resultRects[resultRects.length] = new Rectangle(ix + iw, iy + ih, x + w - ix - iw, y + h - iy - ih);

        return resultRects;
    }

    public static function transformPoint2D(matrix:Matrix, x:Number, y:Number, resultPoint:Point2D = null):Point2D {
        if(resultPoint == null) resultPoint = new Point2D();

        resultPoint.x = matrix.a * x + matrix.c * y + matrix.tx;
        resultPoint.y = matrix.d * y + matrix.b * x + matrix.ty;

        return resultPoint;
    }

    public static function transformBounds2D(matrix:Matrix, x:Number, y:Number, w:Number, h:Number, resultRect:Rectangle2D = null):Rectangle2D {
        if(resultRect == null) resultRect = new Rectangle2D();

        var x1:Number = matrix.a * x + matrix.c * y + matrix.tx;
        var y1:Number = matrix.d * y + matrix.b * x + matrix.ty;
        var x2:Number = matrix.a * (x + w) + matrix.c * (y + h) + matrix.tx;
        var y2:Number = matrix.d * (y + h) + matrix.b * (x + w) + matrix.ty;

        resultRect.setTo(
            x1 < x2 ? x1 : x2,
            y1 < y2 ? y1 : y2,
            Math.abs(x1 - x2),
            Math.abs(y1 - y2)
        );

        return resultRect;
    }
}
}
