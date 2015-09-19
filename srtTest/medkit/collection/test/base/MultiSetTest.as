/**
 * User: booster
 * Date: 19/09/15
 * Time: 14:54
 */
package medkit.collection.test.base {
import medkit.collection.MultiSet;
import medkit.collection.TestSubject;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class MultiSetTest extends SetTest {
    protected var multiSet:MultiSet;

    [Test]
    public function testAddCount():void {
        multiSet.addCount(new TestSubject("123123"), 10);

        assertTrue(collection.contains(new TestSubject("123123")));
        assertEquals(collection.size(), 4);

        assertEquals(multiSet.elementCount(new TestSubject("123123")), 10);

        multiSet.addCount(new TestSubject("123123"), 3);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 13);
    }

    [Test]
    public function testRemoveCount():void {
        multiSet.addCount(new TestSubject("123123"), 10);

        assertTrue(collection.contains(new TestSubject("123123")));
        assertEquals(collection.size(), 4);

        assertEquals(multiSet.elementCount(new TestSubject("123123")), 10);

        multiSet.removeCount(new TestSubject("123123"), 3);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 7);

        multiSet.removeCount(new TestSubject("123123"), 7);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 0);
        assertFalse(multiSet.contains(new TestSubject("123123")));

        multiSet.removeCount(new TestSubject("123123"), 5);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 0);
        assertFalse(multiSet.contains(new TestSubject("123123")));

        multiSet.addCount(new TestSubject("123123"), 3);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 3);
        assertTrue(multiSet.contains(new TestSubject("123123")));
    }

    [Test]
    public function testSetCount():void {
        multiSet.setCount(new TestSubject("123123"), 10);

        assertTrue(collection.contains(new TestSubject("123123")));
        assertEquals(collection.size(), 4);

        assertEquals(multiSet.elementCount(new TestSubject("123123")), 10);

        multiSet.setCount(new TestSubject("123123"), 4);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 4);

        multiSet.setCount(new TestSubject("123123"), 0);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 0);
        assertFalse(multiSet.contains(new TestSubject("123123")));

        multiSet.setCount(new TestSubject("123123"), 5);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 5);
        assertTrue(multiSet.contains(new TestSubject("123123")));

        multiSet.setCount(new TestSubject("123123"), 3);
        assertEquals(multiSet.elementCount(new TestSubject("123123")), 3);
        assertTrue(multiSet.contains(new TestSubject("123123")));
    }

    [Test]
    public function testElementCount():void {
        assertEquals(multiSet.elementCount(valueFirst), 1);
        assertEquals(multiSet.elementCount(valueSecond), 1);
        assertEquals(multiSet.elementCount(valueThird), 1);

        multiSet.addCount(valueFirst, 2);
        multiSet.setCount(valueSecond, 5);
        multiSet.removeCount(valueSecond, 2);
        multiSet.removeCount(valueThird, 5);

        assertEquals(multiSet.elementCount(valueFirst), 3);
        assertEquals(multiSet.elementCount(valueSecond), 3);
        assertEquals(multiSet.elementCount(valueThird), 0);
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

    [Test]
    override public function testToString():void {
        super.testToString();
    }
}
}
