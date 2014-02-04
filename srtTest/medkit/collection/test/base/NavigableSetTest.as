/**
 * User: booster
 * Date: 12/22/12
 * Time: 13:55
 */

package medkit.collection.test.base {

import medkit.collection.NavigableSet;
import medkit.collection.TestSubject;
import medkit.collection.iterator.Iterator;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class NavigableSetTest extends SortedSetTest {
    protected var navigableSet:NavigableSet;

    [Test]
    public function testPollLast():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableSet.pollLast(), e3));
        assertTrue(ObjectUtil.equals(navigableSet.pollLast(), e2));
        assertTrue(ObjectUtil.equals(navigableSet.pollLast(), e1));
        assertTrue(ObjectUtil.equals(navigableSet.pollLast(), null));
    }

    [Test]
    public function testPollFirst():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableSet.pollFirst(), e1));
        assertTrue(ObjectUtil.equals(navigableSet.pollFirst(), e2));
        assertTrue(ObjectUtil.equals(navigableSet.pollFirst(), e3));
        assertTrue(ObjectUtil.equals(navigableSet.pollFirst(), null));
    }

    [Test]
    public function testTailNavigableSet():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var tailSetInclusive:NavigableSet = navigableSet.tailNavigableSet(e2, true);
        var tailSetExclusive:NavigableSet = navigableSet.tailNavigableSet(e1, false);

        assertEquals(tailSetInclusive.size(), 2);
        assertEquals(tailSetExclusive.size(), 2);
        assertEquals(navigableSet.size(), 3);
        assertFalse(tailSetInclusive.contains(e1));
        assertTrue(tailSetInclusive.contains(e2));
        assertTrue(tailSetInclusive.contains(e3));
        assertFalse(tailSetExclusive.contains(e1));
        assertTrue(tailSetExclusive.contains(e2));
        assertTrue(tailSetExclusive.contains(e3));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        tailSetInclusive.add(beforeLastKey);

        assertEquals(tailSetInclusive.size(), 3);
        assertEquals(tailSetExclusive.size(), 3);
        assertEquals(navigableSet.size(), 4);
        assertFalse(tailSetInclusive.contains(e1));
        assertTrue(tailSetInclusive.contains(e2));
        assertTrue(tailSetInclusive.contains(e3));
        assertTrue(tailSetInclusive.contains(beforeLastKey));
        assertFalse(tailSetExclusive.contains(e1));
        assertTrue(tailSetExclusive.contains(e2));
        assertTrue(tailSetExclusive.contains(e3));
        assertTrue(tailSetExclusive.contains(beforeLastKey));
        assertTrue(navigableSet.contains(e1));
        assertTrue(navigableSet.contains(e2));
        assertTrue(navigableSet.contains(e3));
        assertTrue(navigableSet.contains(beforeLastKey));

        tailSetExclusive.add(afterFirstKey);

        assertEquals(tailSetInclusive.size(), 3);
        assertEquals(tailSetExclusive.size(), 4);
        assertEquals(navigableSet.size(), 5);
        assertFalse(tailSetInclusive.contains(e1));
        assertTrue(tailSetInclusive.contains(e2));
        assertTrue(tailSetInclusive.contains(e3));
        assertTrue(tailSetInclusive.contains(beforeLastKey));
        assertFalse(tailSetInclusive.contains(afterFirstKey));
        assertFalse(tailSetExclusive.contains(e1));
        assertTrue(tailSetExclusive.contains(e2));
        assertTrue(tailSetExclusive.contains(e3));
        assertTrue(tailSetExclusive.contains(beforeLastKey));
        assertTrue(tailSetExclusive.contains(afterFirstKey));
        assertTrue(navigableSet.contains(e1));
        assertTrue(navigableSet.contains(e2));
        assertTrue(navigableSet.contains(e3));
        assertTrue(navigableSet.contains(afterFirstKey));
        assertTrue(navigableSet.contains(beforeLastKey));
    }

    [Test]
    public function testSubNavigableSet():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var subSetInclusive:NavigableSet = navigableSet.subNavigableSet(e2, true, e3, false);
        var subSetExclusive:NavigableSet = navigableSet.subNavigableSet(e1, false, e2, true);

        assertEquals(subSetInclusive.size(), 1);
        assertEquals(subSetExclusive.size(), 1);
        assertEquals(navigableSet.size(), 3);
        assertFalse(subSetInclusive.contains(e1));
        assertTrue(subSetInclusive.contains(e2));
        assertFalse(subSetInclusive.contains(e3));
        assertFalse(subSetExclusive.contains(e1));
        assertTrue(subSetExclusive.contains(e2));
        assertFalse(subSetExclusive.contains(e3));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        subSetInclusive.add(beforeLastKey);

        assertEquals(subSetInclusive.size(), 2);
        assertEquals(subSetExclusive.size(), 1);
        assertEquals(navigableSet.size(), 4);
        assertFalse(subSetInclusive.contains(e1));
        assertTrue(subSetInclusive.contains(e2));
        assertFalse(subSetInclusive.contains(e3));
        assertTrue(subSetInclusive.contains(beforeLastKey));
        assertFalse(subSetExclusive.contains(e1));
        assertTrue(subSetExclusive.contains(e2));
        assertFalse(subSetExclusive.contains(e3));
        assertFalse(subSetExclusive.contains(beforeLastKey));
        assertTrue(navigableSet.contains(e1));
        assertTrue(navigableSet.contains(e2));
        assertTrue(navigableSet.contains(e3));
        assertTrue(navigableSet.contains(beforeLastKey));

        subSetExclusive.add(afterFirstKey);

        assertEquals(subSetInclusive.size(), 2);
        assertEquals(subSetExclusive.size(), 2);
        assertEquals(navigableSet.size(), 5);
        assertFalse(subSetInclusive.contains(e1));
        assertTrue(subSetInclusive.contains(e2));
        assertFalse(subSetInclusive.contains(e3));
        assertTrue(subSetInclusive.contains(beforeLastKey));
        assertFalse(subSetInclusive.contains(afterFirstKey));
        assertFalse(subSetExclusive.contains(e1));
        assertTrue(subSetExclusive.contains(e2));
        assertFalse(subSetExclusive.contains(e3));
        assertFalse(subSetExclusive.contains(beforeLastKey));
        assertTrue(subSetExclusive.contains(afterFirstKey));
        assertTrue(navigableSet.contains(e1));
        assertTrue(navigableSet.contains(e2));
        assertTrue(navigableSet.contains(e3));
        assertTrue(navigableSet.contains(afterFirstKey));
        assertTrue(navigableSet.contains(beforeLastKey));
    }

    [Test]
    public function testDescendingIterator():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var descendingIt:Iterator = navigableSet.descendingIterator();

        var descendingE1:TestSubject = descendingIt.next();
        var descendingE2:TestSubject = descendingIt.next();
        var descendingE3:TestSubject = descendingIt.next();

        assertFalse(descendingIt.hasNext());

        assertTrue(ObjectUtil.equals(e1, descendingE3));
        assertTrue(ObjectUtil.equals(e2, descendingE2));
        assertTrue(ObjectUtil.equals(e3, descendingE1));
    }

    [Test]
    public function testHigher():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableSet.higher(e1), e2));
        assertTrue(ObjectUtil.equals(navigableSet.higher(e2), e3));
    }

    [Test]
    public function testCeiling():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var beforeFirstString:String = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1);
        var beforeFirstKey:TestSubject = new TestSubject(beforeFirstString);

        var afterFirstString:String = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject = new TestSubject(afterFirstString);

        assertTrue(ObjectUtil.equals(navigableSet.ceiling(beforeFirstKey), e1));
        assertTrue(ObjectUtil.equals(navigableSet.ceiling(afterFirstKey), e2));
        assertTrue(ObjectUtil.equals(navigableSet.ceiling(e1), e1));
    }

    [Test]
    public function testFloor():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var beforeSecondString:String = TestSubject(e2).str.substr(0, TestSubject(e2).str.length - 1);
        var beforeSecondKey:TestSubject = new TestSubject(beforeSecondString);

        var afterSecondString:String = TestSubject(e2).str.substr(0, TestSubject(e2).str.length - 1) + "z";
        var afterSecondKey:TestSubject = new TestSubject(afterSecondString);

        assertTrue(ObjectUtil.equals(navigableSet.floor(beforeSecondKey), e1));
        assertTrue(ObjectUtil.equals(navigableSet.floor(afterSecondKey), e2));
        assertTrue(ObjectUtil.equals(navigableSet.floor(e1), e1));
    }

    [Test]
    public function testLower():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableSet.lower(e3), e2));
        assertTrue(ObjectUtil.equals(navigableSet.lower(e2), e1));
    }

    [Test]
    public function testDescendingSet():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var descendingNavigableMap:NavigableSet = navigableSet.descendingNavigableSet();

        var descendingIt:Iterator = descendingNavigableMap.iterator();

        var descendingE1:TestSubject = descendingIt.next();
        var descendingE2:TestSubject = descendingIt.next();
        var descendingE3:TestSubject = descendingIt.next();

        assertFalse(descendingIt.hasNext());

        assertTrue(ObjectUtil.equals(e1, descendingE3));
        assertTrue(ObjectUtil.equals(e2, descendingE2));
        assertTrue(ObjectUtil.equals(e3, descendingE1));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        navigableSet.add(afterFirstKey);
        descendingNavigableMap.add(beforeLastKey);

        var otherIt:Iterator = navigableSet.iterator();

        var otherE1:TestSubject     = otherIt.next();
        var afterE1:TestSubject     = otherIt.next();
        var otherE2:TestSubject     = otherIt.next();
        var beforeE3:TestSubject    = otherIt.next();
        var otherE3:TestSubject     = otherIt.next();

        assertFalse(otherIt.hasNext());

        var otherDescendingIt:Iterator = descendingNavigableMap.iterator();

        var otherDescendingE1:TestSubject   = otherDescendingIt.next();
        var afterDescendingE1:TestSubject   = otherDescendingIt.next();
        var otherDescendingE2:TestSubject   = otherDescendingIt.next();
        var beforeDescendingE3:TestSubject  = otherDescendingIt.next();
        var otherDescendingE3:TestSubject   = otherDescendingIt.next();

        assertFalse(otherDescendingIt.hasNext());

        assertTrue(ObjectUtil.equals(otherE1, otherDescendingE3));
        assertTrue(ObjectUtil.equals(afterE1, beforeDescendingE3));
        assertTrue(ObjectUtil.equals(otherE2, otherDescendingE2));
        assertTrue(ObjectUtil.equals(beforeE3, afterDescendingE1));
        assertTrue(ObjectUtil.equals(otherE3, otherDescendingE1));
    }

    [Test]
    public function testHeadNavigableSet():void {
        var it:Iterator = navigableSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var headSetInclusive:NavigableSet = navigableSet.headNavigableSet(e2, true);
        var headSetExclusive:NavigableSet = navigableSet.headNavigableSet(e3, false);

        assertEquals(headSetInclusive.size(), 2);
        assertEquals(headSetExclusive.size(), 2);
        assertEquals(navigableSet.size(), 3);
        assertTrue(headSetInclusive.contains(e1));
        assertTrue(headSetInclusive.contains(e2));
        assertFalse(headSetInclusive.contains(e3));
        assertTrue(headSetExclusive.contains(e1));
        assertTrue(headSetExclusive.contains(e2));
        assertFalse(headSetExclusive.contains(e3));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var afterLastString:String     = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "z";
        var afterLastKey:TestSubject   = new TestSubject(afterLastString);

        headSetInclusive.add(afterFirstKey);

        assertEquals(headSetInclusive.size(), 3);
        assertEquals(headSetExclusive.size(), 3);
        assertEquals(navigableSet.size(), 4);
        assertTrue(headSetInclusive.contains(e1));
        assertTrue(headSetInclusive.contains(e2));
        assertFalse(headSetInclusive.contains(e3));
        assertTrue(headSetInclusive.contains(afterFirstKey));
        assertTrue(headSetExclusive.contains(e1));
        assertTrue(headSetExclusive.contains(e2));
        assertFalse(headSetExclusive.contains(e3));
        assertTrue(headSetExclusive.contains(afterFirstKey));
        assertTrue(navigableSet.contains(e1));
        assertTrue(navigableSet.contains(e2));
        assertTrue(navigableSet.contains(e3));
        assertTrue(navigableSet.contains(afterFirstKey));

        navigableSet.add(afterLastKey);

        assertEquals(headSetInclusive.size(), 3);
        assertEquals(headSetExclusive.size(), 3);
        assertEquals(navigableSet.size(), 5);
        assertTrue(headSetInclusive.contains(e1));
        assertTrue(headSetInclusive.contains(e2));
        assertFalse(headSetInclusive.contains(e3));
        assertTrue(headSetInclusive.contains(afterFirstKey));
        assertFalse(headSetInclusive.contains(afterLastKey));
        assertTrue(headSetExclusive.contains(e1));
        assertTrue(headSetExclusive.contains(e2));
        assertFalse(headSetExclusive.contains(e3));
        assertTrue(headSetExclusive.contains(afterFirstKey));
        assertFalse(headSetExclusive.contains(afterLastKey));
        assertTrue(navigableSet.contains(e1));
        assertTrue(navigableSet.contains(e2));
        assertTrue(navigableSet.contains(e3));
        assertTrue(navigableSet.contains(afterFirstKey));
        assertTrue(navigableSet.contains(afterLastKey));
    }
}

}
