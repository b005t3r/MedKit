/**
 * User: booster
 * Date: 12/8/12
 * Time: 16:00
 */
package medkit.collection.test.base {
import medkit.collection.*;
import medkit.collection.iterator.Iterator;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class CollectionTest {
    protected var collection:Collection;

    protected var valueFirst:Object;
    protected var valueSecond:Object;
    protected var valueThird:Object;

    [Test]
    public function testContains():void {
        assertTrue(collection.contains(valueFirst));
        assertTrue(collection.contains(valueSecond));
        assertTrue(collection.contains(valueThird));

        assertFalse(collection.contains(new TestSubject("nonexistent")));
    }

    [Test]
    public function testRemove():void {
        collection.remove(valueSecond);

        assertTrue(collection.contains(valueFirst));
        assertFalse(collection.contains(valueSecond));
        assertTrue(collection.contains(valueThird));

        collection.remove(valueFirst);

        assertFalse(collection.contains(valueFirst));
        assertFalse(collection.contains(valueSecond));
        assertTrue(collection.contains(valueThird));

        collection.remove(valueThird);

        assertFalse(collection.contains(valueFirst));
        assertFalse(collection.contains(valueSecond));
        assertFalse(collection.contains(valueThird));
    }

    [Test]
    public function testIsEmpty():void {
        assertFalse(collection.isEmpty());

        collection.remove(valueSecond);
        collection.remove(valueFirst);
        collection.remove(valueThird);

        assertTrue(collection.isEmpty());
    }

    [Test]
    public function testSize():void {
        assertEquals(collection.size(), 3);

        collection.remove(valueSecond);

        assertEquals(collection.size(), 2);

        collection.remove(valueFirst);

        assertEquals(collection.size(), 1);

        collection.remove(valueThird);

        assertEquals(collection.size(), 0);
    }

    [Test]
    public function testToArray():void {
        var arr:Array = collection.toArray();

        assertEquals(arr.length, collection.size());

        assertTrue(arrayContains(arr, valueFirst));
        assertTrue(arrayContains(arr, valueSecond));
        assertTrue(arrayContains(arr, valueThird));
    }

    [Test]
    public function testAdd():void {
        collection.add(new TestSubject("123123"));

        assertTrue(collection.contains(new TestSubject("123123")));
        assertEquals(collection.size(), 4);
    }

    [Test]
    public function testRemoveAll():void {
        var clone:Collection        = ObjectUtil.clone(collection, null);
        var newValue:TestSubject    = new TestSubject("1337");

        clone.remove(valueSecond);
        clone.add(newValue);

        collection.removeAll(clone);

        assertFalse(collection.contains(valueFirst));
        assertTrue(collection.contains(valueSecond));
        assertFalse(collection.contains(valueThird));
        assertFalse(collection.contains(newValue));
    }

    [Test]
    public function testRetainAll():void {
        var clone:Collection        = ObjectUtil.clone(collection, null);
        var newValue:TestSubject    = new TestSubject("1337");

        clone.remove(valueSecond);
        clone.add(newValue);

        collection.retainAll(clone);

        assertTrue(collection.contains(valueFirst));
        assertFalse(collection.contains(valueSecond));
        assertTrue(collection.contains(valueThird));
        assertFalse(collection.contains(newValue));

        assertFalse(ObjectUtil.equals(collection, clone));
    }

    [Test]
    public function testIterator():void {
        var it:Iterator = collection.iterator();

        assertTrue(it.hasNext());
        var obj1:* = it.next();
        assertTrue(ObjectUtil.equals(valueFirst, obj1) || ObjectUtil.equals(valueSecond, obj1) || ObjectUtil.equals(valueThird, obj1));
        it.remove();

        assertTrue(it.hasNext());
        var obj2:* = it.next();
        assertTrue(
            ! ObjectUtil.equals(obj1, obj2) &&
            (ObjectUtil.equals(valueFirst, obj2) || ObjectUtil.equals(valueSecond, obj2) || ObjectUtil.equals(valueThird, obj2))
        );
        it.remove();

        assertTrue(it.hasNext());
        var obj3:* = it.next();
        assertTrue(
            ! ObjectUtil.equals(obj3, obj2) && ! ObjectUtil.equals(obj3, obj1) &&
            (ObjectUtil.equals(valueFirst, obj3) || ObjectUtil.equals(valueSecond, obj3) || ObjectUtil.equals(valueThird, obj3))
        );
        it.remove();

        assertFalse(it.hasNext());
    }

    [Test]
    public function testAddAll():void {
        var clone:Collection        = ObjectUtil.clone(collection, null);
        var newValue:TestSubject    = new TestSubject("1337");

        clone.remove(valueSecond);
        clone.add(newValue);

        collection.addAll(clone);

        assertTrue(collection.contains(valueFirst));
        assertTrue(collection.contains(valueSecond));
        assertTrue(collection.contains(valueThird));
        assertTrue(collection.contains(newValue));
    }

    [Test]
    public function testClear():void {
        collection.clear();

        assertTrue(collection.isEmpty());
        assertEquals(collection.size(), 0);
        assertFalse(collection.contains(valueFirst));
        assertFalse(collection.contains(valueSecond));
        assertFalse(collection.contains(valueThird));
    }

    [Test]
    public function testContainsAll():void {
        var clone:Collection        = ObjectUtil.clone(collection, null);
        var newValue:TestSubject    = new TestSubject("1337");

        assertTrue(collection.containsAll(clone));

        clone.remove(valueSecond);

        assertTrue(collection.containsAll(clone));

        clone.add(newValue);

        assertFalse(collection.containsAll(clone));

        clone.remove(newValue);

        assertTrue(collection.containsAll(clone));

        collection.remove(valueFirst);

        assertFalse(collection.containsAll(clone));
    }

    [Test]
    public function testToString():void {
        var str:String = Object(collection).toString();

        assertTrue(str != null);
        assertTrue(str.length > 0);

        trace(str);
    }

    protected function addContent():void {
        valueFirst  = new TestSubject("first value");
        valueSecond = new TestSubject("second value");
        valueThird  = new TestSubject("third value");

        collection.add(valueFirst);
        collection.add(valueSecond);
        collection.add(valueThird);
    }

    protected function arrayContains(arr:Array, obj:*):Boolean {
        for(var i:int = 0; i < arr.length; ++i) {
            if(ObjectUtil.equals(obj, arr[i]))
                return true;
        }

        return false;
    }
}

}
