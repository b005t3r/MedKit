/**
 * User: booster
 * Date: 12/8/12
 * Time: 11:33
 */
package medkit.collection.test.base {
import medkit.collection.*;
import medkit.collection.iterator.ListIterator;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class ListTest extends CollectionTest {
    protected var list:List;

    [Test]
    public function testRemoveAt():void {
        list.removeAt(1);

        assertFalse(list.contains(valueSecond));
        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueThird));

        list.removeAt(1);

        assertFalse(list.contains(valueSecond));
        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertEquals(list.size(), 1);
    }

    [Test]
    public function testSet():void {
        var value:String = "123";

        var err:Boolean = false;
        try { list.set(3, value); } catch(e:RangeError) { err = true; }

        assertTrue(err);

        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(2), valueThird));

        list.set(0, value);

        assertTrue(ObjectUtil.equals(list.get(0), value));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(2), valueThird));

        list.set(1, value);

        assertTrue(ObjectUtil.equals(list.get(0), value));
        assertTrue(ObjectUtil.equals(list.get(1), value));
        assertTrue(ObjectUtil.equals(list.get(2), valueThird));
    }

    [Test]
    public function testAddAt():void {
        var value:String = "123";

        list.addAt(3, value);

        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(2), valueThird));
        assertTrue(ObjectUtil.equals(list.get(3), value));

        list.addAt(0, value);

        assertTrue(ObjectUtil.equals(list.get(0), value));
        assertTrue(ObjectUtil.equals(list.get(1), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(2), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(3), valueThird));
        assertTrue(ObjectUtil.equals(list.get(4), value));

        list.addAt(2, value);

        assertTrue(ObjectUtil.equals(list.get(0), value));
        assertTrue(ObjectUtil.equals(list.get(1), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(2), value));
        assertTrue(ObjectUtil.equals(list.get(3), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(4), valueThird));
        assertTrue(ObjectUtil.equals(list.get(5), value));
    }

    [Test]
    public function testListIterator():void {
        var listIterator:ListIterator = list.listIterator(1);

        assertTrue(listIterator.hasNext());
        assertTrue(ObjectUtil.equals(listIterator.next(), valueSecond));

        assertTrue(listIterator.hasNext());
        assertTrue(ObjectUtil.equals(listIterator.next(), valueThird));

        assertFalse(listIterator.hasNext());
        assertTrue(listIterator.hasPrevious());

        var err:Boolean = false;
        try { listIterator.next(); } catch(e:RangeError) { err = true; }

        assertTrue(err);
    }

    [Test]
    public function testGet():void {
        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(2), valueThird));

        var err:Boolean = false;
        try { list.get(3); } catch(e:RangeError) { err = true; }

        assertTrue(err);
    }

    [Test]
    public function testAddAllAt():void {
        var otherList:List = ObjectUtil.clone(list, null);

        list.addAllAt(2, otherList);

        assertEquals(list.size(), 6);

        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));

        assertTrue(ObjectUtil.equals(list.get(2), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(3), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(4), valueThird));

        assertTrue(ObjectUtil.equals(list.get(5), valueThird));

        var err:Boolean = false;
        try { list.addAllAt(6, otherList); } catch(e:RangeError) { err = true; }

        assertFalse(err);

        err = false;
        try { list.addAllAt(10, otherList); } catch(e:RangeError) { err = true; }

        assertTrue(err);
    }

    [Test]
    public function testLastIndexOf():void {
        list.add("123");
        list.add("321");
        list.add("321");
        list.add("123");

        assertEquals(list.lastIndexOf("123"), 6);
        assertEquals(list.lastIndexOf("321"), 5);
        assertEquals(list.lastIndexOf(valueFirst), 0);
        assertEquals(list.lastIndexOf(valueSecond), 1);
        assertEquals(list.lastIndexOf(valueThird), 2);

        assertEquals(list.lastIndexOf("nonexistent"), -1);
    }

    [Test]
    public function testIndexOf():void {
        list.add("123");
        list.add("321");
        list.add("321");
        list.add("123");

        assertEquals(list.indexOf("123"), 3);
        assertEquals(list.indexOf("321"), 4);
        assertEquals(list.indexOf(valueFirst), 0);
        assertEquals(list.indexOf(valueSecond), 1);
        assertEquals(list.indexOf(valueThird), 2);

        assertEquals(list.indexOf("nonexistent"), -1);
    }

    [Test]
    public function testRemoveRange():void {
        list.add("123");
        list.add("321");
        list.add("abc");
        list.add("cba");

        assertEquals(list.size(), 7);
        assertEquals(list.indexOf(valueFirst), 0);
        assertEquals(list.indexOf(valueSecond), 1);
        assertEquals(list.indexOf(valueThird), 2);
        assertEquals(list.indexOf("123"), 3);
        assertEquals(list.indexOf("321"), 4);
        assertEquals(list.indexOf("abc"), 5);
        assertEquals(list.indexOf("cba"), 6);

        list.removeRange(2, 5);

        assertEquals(list.size(), 4);
        assertEquals(list.indexOf(valueFirst), 0);
        assertEquals(list.indexOf(valueSecond), 1);
        assertEquals(list.indexOf("abc"), 2);
        assertEquals(list.indexOf("cba"), 3);

        list.removeRange(0, 4);

        assertEquals(list.size(), 0);
    }

    [Test]
    public function testSubList():void {
        var sublist:List = list.subList(1, 3);

        assertEquals(sublist.size(), 2);
        assertTrue(ObjectUtil.equals(sublist.get(0), valueSecond));
        assertTrue(ObjectUtil.equals(sublist.get(1), valueThird));

        sublist.add("123");
        sublist.addAt(1, "321");

        assertEquals(sublist.size(), 4);
        assertTrue(ObjectUtil.equals(sublist.get(0), valueSecond));
        assertTrue(ObjectUtil.equals(sublist.get(1), "321"));
        assertTrue(ObjectUtil.equals(sublist.get(2), valueThird));
        assertTrue(ObjectUtil.equals(sublist.get(3), "123"));

        assertEquals(list.size(), 5);
        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(2), "321"));
        assertTrue(ObjectUtil.equals(list.get(3), valueThird));
        assertTrue(ObjectUtil.equals(list.get(4), "123"));

        sublist.removeRange(1, 3);

        assertEquals(sublist.size(), 2);
        assertTrue(ObjectUtil.equals(sublist.get(0), valueSecond));
        assertTrue(ObjectUtil.equals(sublist.get(1), "123"));

        assertEquals(list.size(), 3);
        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
        assertTrue(ObjectUtil.equals(list.get(1), valueSecond));
        assertTrue(ObjectUtil.equals(list.get(2), "123"));

        sublist.clear();
        assertEquals(sublist.size(), 0);

        assertEquals(list.size(), 1);
        assertTrue(ObjectUtil.equals(list.get(0), valueFirst));
    }

    [Test]
    override public function testContains():void {
        super.testContains();
    }

    [Test]
    override public function testRemove():void {
        super.testRemove();
    }

    [Test]
    override public function testIsEmpty():void {
        super.testIsEmpty();
    }

    [Test]
    override public function testSize():void {
        super.testSize();
    }

    [Test]
    override public function testToArray():void {
        super.testToArray();
    }

    [Test]
    override public function testAdd():void {
        super.testAdd();
    }

    [Test]
    override public function testRemoveAll():void {
        super.testRemoveAll();
    }

    [Test]
    override public function testRetainAll():void {
        super.testRetainAll();
    }

    [Test]
    override public function testIterator():void {
        super.testIterator();
    }

    [Test]
    override public function testAddAll():void {
        super.testAddAll();
    }

    [Test]
    override public function testClear():void {
        super.testClear();
    }

    [Test]
    override public function testContainsAll():void {
        super.testContainsAll();
    }

    override protected function arrayContains(arr:Array, obj:*):Boolean {
        return super.arrayContains(arr, obj);
    }
}

}
