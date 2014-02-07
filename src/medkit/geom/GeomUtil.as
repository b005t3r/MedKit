/**
 * User: booster
 * Date: 07/02/14
 * Time: 8:54
 */
package medkit.geom {
import flash.geom.Point;
import flash.geom.Rectangle;

public class GeomUtil {
    public static function angleBetweenPoints(a:Point, b:Point):Number {
        var dy:Number = b.y - a.y;
        var dx:Number = b.x - a.x;

        return (Math.atan2(dx, -dy) + 2 * Math.PI) % (2 * Math.PI);
    }

    public static function projectPoint(source:Point, angle:Number, distance:Number):Point {
        return new Point(
            (source.x + Math.sin(angle) * distance),
            (source.y - Math.cos(angle) * distance)    // minus when Y-Axis is going down, plus when it's going up
        );
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

        if(intersectionPoint != null) {}
        intersectionPoint.setTo((B2 * C1 - B1 * C2) / det, (A1 * C2 - A2 * C1) / det);

        return true;
    }

    public static function circlesIntersection(firstCircle:Point, firstRadius:Number, secondCircle:Point, secondRadius:Number):Vector.<Point> {
        var distance:Number = Point.distance(firstCircle, secondCircle);

        // no intersection
        if(distance > firstRadius + secondRadius
               || distance < Math.abs(firstRadius - secondRadius)
            || distance == 0)
            return new <Point>[];

        // single intersection point
        if(distance == firstRadius + secondRadius) {
            var angle:Number = angleBetweenPoints(firstCircle, secondCircle);
            var point:Point = projectPoint(firstCircle, angle, firstRadius);

            return new <Point>[point];
        }

        // two intersection points
        var ang:Number = angleBetweenPoints(firstCircle, secondCircle);
        var a:Number = (firstRadius * firstRadius - secondRadius * secondRadius + distance * distance) / (2 * distance);
        var p:Point = projectPoint(firstCircle, ang, a);
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
        var x1:Number = Math.max(rect.left, otherRect.left),
            y1:Number = Math.max(rect.top, otherRect.top),
            x2:Number = Math.min(rect.right, otherRect.right),
            y2:Number = Math.min(rect.bottom, otherRect.bottom);

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
}
}
