/**
 * User: booster
 * Date: 14/05/14
 * Time: 13:53
 */
package medkit.geom.shapes {
import flash.geom.Matrix;

import medkit.collection.spatial.Spatial;
import medkit.geom.shapes.crossings.Crossings;
import medkit.geom.shapes.crossings.EvenOdd;
import medkit.object.Cloneable;
import medkit.object.CloningContext;
import medkit.object.Equalable;
import medkit.object.Hashable;
import medkit.object.ObjectUtil;

public class Polygon2D implements Shape2D, Equalable, Hashable, Cloneable, Spatial {
    private static const MIN_LENGTH:int = 4;

    private var _points:Array               = [];
    private var _pointCount:int             = 0;

    private var _bounds:Rectangle2D         = new Rectangle2D();
    private var _boundsInvalid:Boolean      = true;

    public function Polygon2D() {
        _points.length = MIN_LENGTH;
    }

    public function get pointCount():int { return _pointCount; }
    public function getPoint2D(index:int):Point2D { return _points[index]; }

    public function reset():void {
        for(var i:int = 0; i < _pointCount; ++i)
            _points[i] = null;

        _pointCount     = 0;
        _boundsInvalid  = true;
    }

    public function invalidate():void {
        _boundsInvalid = true;
    }

    public function translate(x:Number, y:Number):void {
        for(var i:int = 0; i < _pointCount; ++i) {
            var point:Point2D = _points[i];
            point.x += x;
            point.y += y;
        }

        if(! _boundsInvalid)
            _bounds.offset(x, y);
    }

    public function getBounds(result:Rectangle2D = null):Rectangle2D {
        if(_boundsInvalid)
            validateBounds();

        return _bounds.getBounds(result);
    }

    public function add(x:Number, y:Number):void {
        if (_pointCount >= _points.length) {
            var newLength:int = _pointCount * 2;

            if (newLength < MIN_LENGTH)
                newLength = MIN_LENGTH;

            _points.length = newLength;
        }

        var p:Point2D = new Point2D(x, y);

        _points[_pointCount] = p;
        ++_pointCount;

        if(! _boundsInvalid)
            updateBounds(p);
    }

    public function addPoint2D(p:Point2D, clone:Boolean = true):void {
        if (_pointCount >= _points.length) {
            var newLength:int = _pointCount * 2;

            if (newLength < MIN_LENGTH)
                newLength = MIN_LENGTH;

            _points.length = newLength;
        }

        _points[_pointCount] = clone ? p.clone() as Point2D : p;
        ++_pointCount;

        if(! _boundsInvalid)
            updateBounds(p);
    }

    public function intersectsRect(x:Number, y:Number, w:Number, h:Number):Boolean {
        if(_pointCount <= 0)
            return false;

        if(_boundsInvalid)
            validateBounds();

        if(!_bounds.intersectsRect(x, y, w, h))
            return false;

        var cross:Crossings = getCrossings(x, y, x + w, y + h);

        return (cross == null || ! cross.isEmpty());
    }

    public function intersectsRectangle2D(rect:Rectangle2D):Boolean {
        return intersectsRect(rect.x, rect.y, rect.width, rect.height);
    }

    public function contains(x:Number, y:Number):Boolean {
        if (_pointCount <= 2)
            return false;

        if(_boundsInvalid)
            validateBounds();

        if(! _bounds.contains(x, y))
            return false;

        var hits:int = 0;

        var last:Point2D = _points[_pointCount - 1];
        var curr:Point2D;

        // Walk the edges of the polygon
        for (var i:int = 0; i < _pointCount; last = curr, ++i) {
            curr = _points[i];

            if (curr == last)
                continue;

            var left:Point2D;

            if (curr.x < last.x) {
                if (x >= last.x)
                    continue;

                left = curr;
            }
            else {
                if (x >= curr.x)
                    continue;

                left = last;
            }

            var test1:Number, test2:Number;
            if (curr.y < last.y) {
                if (y < curr.y || y >= last.y)
                    continue;

                if (x < left.x) {
                    hits++;
                    continue;
                }

                test1 = x - curr.x;
                test2 = y - curr.y;
            } else {
                if (y < last.y || y >= curr.y)
                    continue;

                if(x < left.x) {
                    hits++;
                    continue;
                }

                test1 = x - last.x;
                test2 = y - last.y;
            }

            if (test1 < (test2 / (last.y - curr.y) * (last.x - curr.x)))
                hits++;
        }

        return ((hits & 1) != 0);
    }

    public function containsPoint2D(p:Point2D):Boolean {
        return contains(p.x, p.y);
    }

    public function containsRect(x:Number, y:Number, w:Number, h:Number):Boolean {
        if(_pointCount <= 0)
            return false;

        if(_boundsInvalid)
            validateBounds();

        if(!_bounds.intersectsRect(x, y, w, h))
            return false;

        var cross:Crossings = getCrossings(x, y, x + w, y + h);
        return (cross != null && cross.covers(y, y + h));
    }

   public function containsRectangle2D(rect:Rectangle2D):Boolean {
        return containsRect(rect.x, rect.y, rect.width, rect.height);
    }

    public function getPathIterator(transformMatrix:Matrix = null, flatness:Number = 0):PathIterator {
        return new PolyIterator(this, _points, _pointCount, transformMatrix);
    }

    public function equals(object:Equalable):Boolean {
        var poly:Polygon2D = object as Polygon2D;

        if(poly == null)
            return false;

        if(_pointCount != poly._pointCount)
            return false;

        var startIndex:int, count:int = _points.length;
        for(startIndex = 0; startIndex < count; ++startIndex) {
            var point:Point2D = _points[startIndex];

            if(ObjectUtil.equals(point, poly._points[0]))
                break;
        }

        if(startIndex == count)
            return false;

        for(var i:int = 0; i < count; ++i) {
            var polyPoint:Point2D = poly._points[i];
            var thisPoint:Point2D = _points[(i + startIndex) % count];

            if(! ObjectUtil.equals(thisPoint, polyPoint))
                return false;
        }

        return true;
    }

    public function hashCode():int { return _bounds.hashCode(); }

    public function clone(cloningContext:CloningContext = null):Cloneable {
        var clone:Polygon2D;

        if(cloningContext != null) {
            clone = cloningContext.fetchClone(this);

            if(clone != null)
                return clone;

            clone                   = cloningContext.registerClone(this, new Polygon2D());
            clone._points           = ObjectUtil.clone(this._points, cloningContext);
            clone._pointCount       = this._pointCount;
            clone._bounds           = ObjectUtil.clone(this._bounds, cloningContext);
            clone._boundsInvalid    = this._boundsInvalid;
        }
        else {
            clone                   = new Polygon2D();
            clone._points           = this._points;
            clone._pointCount       = this._pointCount;
            clone._bounds           = this._bounds;
            clone._boundsInvalid    = this._boundsInvalid;
        }

        return clone;
    }

    public function get indexCount():int { return _bounds.indexCount; }
    public function minValue(index:int):Number { return _bounds.minValue(index); }
    public function maxValue(index:int):Number { return _bounds.maxValue(index); }

    private function validateBounds():void {
        _boundsInvalid = false;

        if(_pointCount == 0) {
            _bounds.setEmpty();
            return;
        }

        var boundsMinX:Number = Number.MAX_VALUE,
            boundsMinY:Number = Number.MAX_VALUE,
            boundsMaxX:Number = Number.MIN_VALUE,
            boundsMaxY:Number = Number.MIN_VALUE;

        for (var i:int = 0; i < _pointCount; ++i) {
            var p:Point2D = _points[i];

            boundsMinX = boundsMinX < p.x ? boundsMinX : p.x;
            boundsMaxX = boundsMaxX > p.x ? boundsMaxX : p.x;
            boundsMinY = boundsMinY < p.y ? boundsMinY : p.y;
            boundsMaxY = boundsMaxY > p.y ? boundsMaxY : p.y;
        }

        _bounds.setTo(boundsMinX, boundsMinY, boundsMaxX - boundsMinX, boundsMaxY - boundsMinY);
    }

    private function updateBounds(p:Point2D):void {
        if (p.x < _bounds.x) {
            _bounds.width = _bounds.width + (_bounds.x - p.x);
            _bounds.x = p.x;
        }
        else {
            _bounds.width = _bounds.width > p.x - _bounds.x ? _bounds.width : p.x - _bounds.x;
            // bounds.x = bounds.x;
        }

        if (p.y < _bounds.y) {
            _bounds.height = _bounds.height + (_bounds.y - p.y);
            _bounds.y = p.y;
        }
        else {
            _bounds.height = _bounds.height > p.y - _bounds.y ? _bounds.height : p.y - _bounds.y;
            // bounds.y = bounds.y;
        }
    }

    private function getCrossings(xlo:Number, ylo:Number, xhi:Number, yhi:Number):Crossings {
        var cross:Crossings = new EvenOdd(xlo, ylo, xhi, yhi);
        var last:Point2D = _points[_pointCount - 1];
        var curr:Point2D;

        // Walk the edges of the polygon
        for(var i:int = 0; i < _pointCount; ++i) {
            curr = _points[i];
            if(cross.accumulateLine(last.x, last.y, curr.x, curr.y))
                return null;

            last = curr;
        }

        return cross;
    }
}
}

import flash.geom.Matrix;

import medkit.geom.GeomUtil;
import medkit.geom.shapes.PathIterator;
import medkit.geom.shapes.Point2D;
import medkit.geom.shapes.Polygon2D;
import medkit.geom.shapes.enum.SegmentType;
import medkit.geom.shapes.enum.WindingRule;

class PolyIterator implements PathIterator {
    public var poly:Polygon2D;
    public var points:Array;
    public var pointCount:int;
    public var matrix:Matrix;
    public var index:int;

    public function PolyIterator(poly:Polygon2D, points:Array, pointCount:int, matrix:Matrix = null) {
        this.poly       = poly;
        this.matrix     = matrix;
        this.index      = pointCount > 0 ? 0 : 1;
        this.points     = points;
        this.pointCount = pointCount;
    }

    public function getWindingRule():WindingRule { return WindingRule.EvenOdd; }

    public function isDone():Boolean { return index > pointCount; }

    public function next():void { ++index; }

    public function currentSegment(coords:Vector.<Point2D>):SegmentType {
        if (index >= pointCount)
            return SegmentType.Close;

        coords[0].x = points[index].x;
        coords[0].y = points[index].y;

        if (matrix != null)
            GeomUtil.transformPoint2D(matrix, coords[0].x, coords[0].y, coords[0]);

        return (index == 0 ? SegmentType.MoveTo : SegmentType.LineTo);
    }
}
