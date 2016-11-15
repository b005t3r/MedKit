/**
 * User: booster
 * Date: 16/02/14
 * Time: 15:20
 */
package medkit.collection.test {
import flash.geom.Rectangle;

import medkit.collection.ArrayList;
import medkit.collection.Collection;
import medkit.collection.iterator.Iterator;
import medkit.collection.spatial.SpatialSet;
import medkit.collection.test.base.SetTest;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class SpatialSetTest extends SetTest {
    private var spatialSet:SpatialSet;

    private var rect1:Rectangle, rect2:Rectangle, rect3:Rectangle;
    private var spatial1:SpatialRectangle, spatial2:SpatialRectangle, spatial3:SpatialRectangle;

    private var overlapping1:Rectangle, overlapping2:SpatialRectangle, notOverlapping1:Rectangle, notOverlapping2:SpatialRectangle;

    [Before]
    public function setUp():void {
        collection = set = spatialSet =new SpatialSet([5, -50, 50, 10, -75, 75], new TestSpatializer());

        addContent();
    }

    [After]
    public function tearDown():void {
        collection = set = spatialSet =null;
    }

    [Test]
    public function testSearch():void {
        var list:ArrayList = new ArrayList();
        var result:Collection;

        result = spatialSet.search(overlapping1);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(rect2));
        assertEquals(result.size(), 2);

        result = spatialSet.search(overlapping1, true);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(rect2));
        assertTrue(result.size() >= 2);

        result = spatialSet.search(overlapping2, true, true, list);

        assertEquals(result, list);
        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(spatial2));
        assertTrue(result.contains(rect1));
        assertTrue(result.size() >= 3);

        list.clear();

        result = spatialSet.search(overlapping2, false, true, list);

        assertEquals(result, list);
        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(spatial2));
        assertTrue(result.contains(rect1));
        assertEquals(result.size(), 3);

        result = spatialSet.search(notOverlapping1);

        assertEquals(result.size(), 0);

        list.clear();
        result = spatialSet.search(notOverlapping2, false, true, list);

        assertEquals(result, list);
        assertEquals(result.size(), 0);
    }

    [Test]
    public function testUpdate():void {
        var result:Collection;

        result = spatialSet.search(overlapping1);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(rect2));
        assertEquals(result.size(), 2);

        result = spatialSet.search(overlapping2);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(spatial2));
        assertTrue(result.contains(rect1));
        assertEquals(result.size(), 3);

        result = spatialSet.search(notOverlapping1);

        assertEquals(result.size(), 0);

        result = spatialSet.search(notOverlapping2);

        assertEquals(result.size(), 0);

        spatialSet.mark(rect1);
        rect1.offset(20, 5); // now does not overlap with overlapping2 and does overlap with notOverlapping2
        spatialSet.updateMarked();

        result = spatialSet.search(overlapping1);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(rect2));
        assertEquals(result.size(), 2);

        result = spatialSet.search(overlapping2);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(spatial2));
        assertFalse(result.contains(rect1));
        assertEquals(result.size(), 2);

        result = spatialSet.search(notOverlapping1);

        assertEquals(result.size(), 0);

        result = spatialSet.search(notOverlapping2);

        assertTrue(result.contains(rect1));
        assertEquals(result.size(), 1);

        spatialSet.mark(rect1);
        spatialSet.mark(spatial2);

        rect1.offset(-20, -5); // returns to the previous position
        spatial2.offset(-40, -70); // now does not overlap with overlapping2 and does overlap with notOverlapping1

        spatialSet.updateMarked(false);

        result = spatialSet.search(overlapping1);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(rect2));
        assertEquals(result.size(), 2);

        result = spatialSet.search(overlapping2);

        assertTrue(result.contains(spatial1));
        assertFalse(result.contains(spatial2));
        assertTrue(result.contains(rect1));
        assertEquals(result.size(), 2);

        result = spatialSet.search(notOverlapping1);

        assertTrue(result.contains(spatial2));
        assertEquals(result.size(), 1);

        result = spatialSet.search(notOverlapping2);

        assertEquals(result.size(), 0);

        rect1.offset(20, 5); // now does not overlap with overlapping2 and does overlap with notOverlapping2
        spatial2.offset(40, 70); // returns to the previous position

        spatialSet.updateMarked();

        result = spatialSet.search(overlapping1);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(rect2));
        assertEquals(result.size(), 2);

        result = spatialSet.search(overlapping2);

        assertTrue(result.contains(spatial1));
        assertTrue(result.contains(spatial2));
        assertFalse(result.contains(rect1));
        assertEquals(result.size(), 2);

        result = spatialSet.search(notOverlapping1);

        assertEquals(result.size(), 0);

        result = spatialSet.search(notOverlapping2);

        assertTrue(result.contains(rect1));
        assertEquals(result.size(), 1);
    }

    [Test]
    override public function testContains():void {
        assertTrue(collection.contains(rect1));
        assertTrue(collection.contains(spatial2));
        assertTrue(collection.contains(rect3));

        assertFalse(collection.contains(new Rectangle(100, 100, 100, 100)));
    }

    [Test]
    override public function testRemove():void {
        collection.remove(rect2);

        assertTrue(collection.contains(rect1));
        assertFalse(collection.contains(rect2));
        assertTrue(collection.contains(rect3));

        collection.remove(spatial1);

        assertFalse(collection.contains(spatial1));
        assertFalse(collection.contains(rect2));
        assertTrue(collection.contains(spatial3));

        collection.remove(spatial3);

        assertFalse(collection.contains(spatial1));
        assertFalse(collection.contains(rect2));
        assertFalse(collection.contains(spatial3));
    }

    [Test]
    override public function testIsEmpty():void {
        assertFalse(collection.isEmpty());

        collection.remove(rect1);
        collection.remove(spatial2);
        collection.remove(rect3);

        assertFalse(collection.isEmpty());

        collection.remove(spatial1);
        collection.remove(rect2);
        collection.remove(spatial3);

        assertTrue(collection.isEmpty());
    }

    [Test]
    override public function testSize():void {
        assertEquals(collection.size(), 6);

        collection.remove(spatial2);

        assertEquals(collection.size(), 5);

        collection.remove(rect3);

        assertEquals(collection.size(), 4);

        collection.remove(spatial1);

        assertEquals(collection.size(), 3);

        collection.remove(rect1);

        assertEquals(collection.size(), 2);

        collection.remove(spatial3);

        assertEquals(collection.size(), 1);

        collection.remove(rect2);

        assertEquals(collection.size(), 0);
    }

    [Test]
    override public function testToArray():void {
        var arr:Array = collection.toArray();

        assertEquals(arr.length, collection.size());

        assertTrue(arrayContains(arr, rect1));
        assertTrue(arrayContains(arr, rect2));
        assertTrue(arrayContains(arr, rect3));
        assertTrue(arrayContains(arr, spatial1));
        assertTrue(arrayContains(arr, spatial2));
        assertTrue(arrayContains(arr, spatial3));
    }

    [Test]
    override public function testAdd():void {
        collection.add(new SpatialRectangle(1000, 1000, 30, 30));

        assertTrue(collection.contains(new SpatialRectangle(1000, 1000, 30, 30)));
        assertEquals(collection.size(), 7);
    }

    [Test]
    override public function testRemoveAll():void {
        var clone:Collection    = ObjectUtil.clone(collection, null);
        var newValue:Rectangle  = new Rectangle(0, 0, 50, 12);

        clone.remove(rect2);
        clone.add(newValue);

        collection.removeAll(clone);

        assertFalse(collection.contains(rect1));
        assertTrue(collection.contains(rect2));
        assertFalse(collection.contains(spatial3));
        assertFalse(collection.contains(newValue));
    }

    [Test]
    override public function testRetainAll():void {
        var clone:Collection      = ObjectUtil.clone(collection, null);
        var newValue:Rectangle    = new Rectangle(43, 12.5, 15, 70);

        clone.remove(rect2);
        clone.add(newValue);

        collection.retainAll(clone);

        assertTrue(collection.contains(rect1));
        assertFalse(collection.contains(rect2));
        assertTrue(collection.contains(spatial3));
        assertFalse(collection.contains(newValue));

        assertFalse(ObjectUtil.equals(collection, clone));
    }

    [Test]
    override public function testIterator():void {
        collection.remove(spatial2);
        collection.remove(rect1);
        collection.remove(rect3);

        var it:Iterator = collection.iterator();

        assertTrue(it.hasNext());
        var obj1:* = it.next();
        assertTrue(ObjectUtil.equals(spatial1, obj1) || ObjectUtil.equals(rect2, obj1) || ObjectUtil.equals(spatial3, obj1));

        assertTrue(it.hasNext());
        var obj2:* = it.next();
        assertTrue(
            ! ObjectUtil.equals(obj1, obj2) &&
            (ObjectUtil.equals(spatial1, obj1) || ObjectUtil.equals(rect2, obj1) || ObjectUtil.equals(spatial3, obj1))
        );

        assertTrue(it.hasNext());
        var obj3:* = it.next();
        assertTrue(
            ! ObjectUtil.equals(obj3, obj2) && ! ObjectUtil.equals(obj3, obj1) &&
            (ObjectUtil.equals(spatial1, obj1) || ObjectUtil.equals(rect2, obj1) || ObjectUtil.equals(spatial3, obj1))
        );

        assertFalse(it.hasNext());
    }

    [Test]
    override public function testAddAll():void {
        var clone:Collection            = ObjectUtil.clone(collection, null);
        var newValue:SpatialRectangle   = new SpatialRectangle(12.33, -21.5, 30, 20);

        clone.remove(rect2);
        clone.add(newValue);

        collection.addAll(clone);

        assertTrue(collection.contains(rect1));
        assertTrue(collection.contains(spatial2));
        assertTrue(collection.contains(rect3));
        assertTrue(collection.contains(newValue));

        assertEquals(collection.size(), 7);
    }

    [Test]
    override public function testClear():void {
        collection.clear();

        assertTrue(collection.isEmpty());
        assertEquals(collection.size(), 0);
        assertFalse(collection.contains(rect1));
        assertFalse(collection.contains(rect2));
        assertFalse(collection.contains(rect3));
        assertFalse(collection.contains(spatial1));
        assertFalse(collection.contains(spatial2));
        assertFalse(collection.contains(spatial3));
    }

    [Test]
    override public function testContainsAll():void {
        var clone:Collection            = ObjectUtil.clone(collection, null);
        var newValue:SpatialRectangle   = new SpatialRectangle(70, 65, 30, 15);

        assertTrue(collection.containsAll(clone));

        clone.remove(rect2);

        assertTrue(collection.containsAll(clone));

        clone.add(newValue);

        assertFalse(collection.containsAll(clone));

        clone.remove(newValue);

        assertTrue(collection.containsAll(clone));

        collection.remove(spatial1);

        assertFalse(collection.containsAll(clone));
    }

    [Test]
    override public function testToString():void {
        super.testToString();
    }

    override protected function addContent():void {
        rect1 = new Rectangle(10, 10, 10, 10);
        rect2 = new Rectangle(50, -20, 30, 70);
        rect3 = new Rectangle(-100, -100, 10, 10);

        spatial1 = new SpatialRectangle(-10, -10, 10, 10);
        spatial2 = new SpatialRectangle(-50, 20, 30, 70);
        spatial3 = new SpatialRectangle(100, 100, 10, 10);

        set.add(rect1); set.add(rect2); set.add(rect3);
        set.add(spatial1); set.add(spatial2); set.add(spatial3);

        overlapping1 = new Rectangle(-5, -45, 55, 35); // overlaps: spatial1, rect2
        overlapping2 = new SpatialRectangle(-20, -5, 45, 45); // overlaps: spatial1, spatial2, rect1

        notOverlapping1 = new Rectangle(-100, -60, 20, 20);
        notOverlapping2 = new SpatialRectangle(20, 25, 15, 15);
    }
}
}

import flash.geom.Rectangle;

import medkit.collection.spatial.Spatial;
import medkit.collection.spatial.Spatializer;
import medkit.object.Equalable;

class SpatialRectangle implements Spatial, Equalable {
    public var x:Number, y:Number, width:Number, height:Number;

    public function SpatialRectangle(x:Number, y:Number, w:Number, h:Number) {
        this.x = x;
        this.y = y;
        this.width = w;
        this.height = h;
    }

    public function offset(x:Number, y:Number):void {
        this.x += x;
        this.y += y;
    }

    public function get indexCount():int { return 2; }

    public function minValue(index:int):Number {
        if(index == 0)      return x;
        else if(index == 1) return y;
        else                throw new ArgumentError("index out of bounds: " + index);
    }

    public function maxValue(index:int):Number {
        if(index == 0)      return x + width;
        else if(index == 1) return y + height;
        else                throw new ArgumentError("index out of bounds: " + index);
    }

    public function equals(object:Equalable):Boolean {
        var s:SpatialRectangle = object as SpatialRectangle;

        if(s == null) return false;

        return s.x == x && s.y == y && s.width == width && s.height == height;
    }
}

class TestSpatializer implements Spatializer {
    public function indexCount(obj:*):int {
        if(obj is Rectangle == false)
            throw new ArgumentError("obj is not a Rectangle: " + obj);

        return 2;
    }

    public function minValue(obj:*, index:int):Number {
        var rect:Rectangle = obj as Rectangle;

        if(index == 0)      return rect.left;
        else if(index == 1) return rect.top;
        else                throw new ArgumentError("index out of bounds: " + index);
    }

    public function maxValue(obj:*, index:int):Number {
        var rect:Rectangle = obj as Rectangle;

        if(index == 0)      return rect.right;
        else if(index == 1) return rect.bottom;
        else                throw new ArgumentError("index out of bounds: " + index);
    }
}
