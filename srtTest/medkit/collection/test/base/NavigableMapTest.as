/**
 * User: booster
 * Date: 12/18/12
 * Time: 21:10
 */

package medkit.collection.test.base {

import medkit.collection.MapEntry;
import medkit.collection.NavigableMap;
import medkit.collection.NavigableSet;
import medkit.collection.TestSubject;
import medkit.collection.iterator.Iterator;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class NavigableMapTest extends SortedMapTest {
    protected var navigableMap:NavigableMap;

    [Test]
    public function testFirstEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.firstEntry(), e1));
    }

    [Test]
    public function testHigherEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.higherEntry(e1.getKey()), e2));
        assertTrue(ObjectUtil.equals(navigableMap.higherEntry(e2.getKey()), e3));
    }

    [Test]
    public function testHeadNavigableMap():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var headMapInclusive:NavigableMap = navigableMap.headNavigableMap(e2.getKey(), true);
        var headMapExclusive:NavigableMap = navigableMap.headNavigableMap(e3.getKey(), false);

        assertEquals(headMapInclusive.size(), 2);
        assertEquals(headMapExclusive.size(), 2);
        assertEquals(sortedMap.size(), 3);
        assertTrue(headMapInclusive.containsKey(e1.getKey()));
        assertTrue(headMapInclusive.containsKey(e2.getKey()));
        assertFalse(headMapInclusive.containsKey(e3.getKey()));
        assertTrue(headMapExclusive.containsKey(e1.getKey()));
        assertTrue(headMapExclusive.containsKey(e2.getKey()));
        assertFalse(headMapExclusive.containsKey(e3.getKey()));

        var afterFirstString:String     = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var afterLastString:String      = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "z";
        var afterLastKey:TestSubject    = new TestSubject(afterLastString);

        headMapInclusive.put(afterFirstKey, "some value");

        assertEquals(headMapInclusive.size(), 3);
        assertEquals(headMapExclusive.size(), 3);
        assertEquals(sortedMap.size(), 4);
        assertTrue(headMapInclusive.containsKey(e1.getKey()));
        assertTrue(headMapInclusive.containsKey(e2.getKey()));
        assertFalse(headMapInclusive.containsKey(e3.getKey()));
        assertTrue(headMapInclusive.containsKey(afterFirstKey));
        assertTrue(headMapExclusive.containsKey(e1.getKey()));
        assertTrue(headMapExclusive.containsKey(e2.getKey()));
        assertFalse(headMapExclusive.containsKey(e3.getKey()));
        assertTrue(headMapExclusive.containsKey(afterFirstKey));
        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(afterFirstKey));

        navigableMap.put(afterLastKey, "some other value");

        assertEquals(headMapInclusive.size(), 3);
        assertEquals(headMapExclusive.size(), 3);
        assertEquals(sortedMap.size(), 5);
        assertTrue(headMapInclusive.containsKey(e1.getKey()));
        assertTrue(headMapInclusive.containsKey(e2.getKey()));
        assertFalse(headMapInclusive.containsKey(e3.getKey()));
        assertTrue(headMapInclusive.containsKey(afterFirstKey));
        assertFalse(headMapInclusive.containsKey(afterLastKey));
        assertTrue(headMapExclusive.containsKey(e1.getKey()));
        assertTrue(headMapExclusive.containsKey(e2.getKey()));
        assertFalse(headMapExclusive.containsKey(e3.getKey()));
        assertTrue(headMapExclusive.containsKey(afterFirstKey));
        assertFalse(headMapExclusive.containsKey(afterLastKey));
        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(afterFirstKey));
        assertTrue(sortedMap.containsKey(afterLastKey));
    }

    [Test]
    public function testNavigableKeySet():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var navigableKeySet:NavigableSet = navigableMap.navigableKeySet();

        var keyIt:Iterator = navigableKeySet.iterator();

        var k1:TestSubject = keyIt.next();
        var k2:TestSubject = keyIt.next();
        var k3:TestSubject = keyIt.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(e1.getKey(), k1));
        assertTrue(ObjectUtil.equals(e2.getKey(), k2));
        assertTrue(ObjectUtil.equals(e3.getKey(), k3));

        var afterFirstString:String     = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        navigableMap.put(afterFirstKey, "value");
        navigableMap.put(beforeLastKey, "other value");

        var otherIt:Iterator = navigableMap.entrySet().iterator();

        var otherE1:MapEntry    = otherIt.next();
        var afterE1:MapEntry    = otherIt.next();
        var otherE2:MapEntry    = otherIt.next();
        var beforeE3:MapEntry   = otherIt.next();
        var otherE3:MapEntry    = otherIt.next();

        assertFalse(otherIt.hasNext());

        var otherKeyIt:Iterator = navigableKeySet.iterator();

        var otherK1:TestSubject     = otherKeyIt.next();
        var afterK1:TestSubject     = otherKeyIt.next();
        var otherK2:TestSubject     = otherKeyIt.next();
        var beforeK3:TestSubject    = otherKeyIt.next();
        var otherK3:TestSubject     = otherKeyIt.next();

        assertFalse(otherKeyIt.hasNext());

        assertTrue(ObjectUtil.equals(otherE1.getKey(), otherK1));
        assertTrue(ObjectUtil.equals(otherE2.getKey(), otherK2));
        assertTrue(ObjectUtil.equals(otherE3.getKey(), otherK3));
        assertTrue(ObjectUtil.equals(afterE1.getKey(), afterK1));
        assertTrue(ObjectUtil.equals(beforeE3.getKey(), beforeK3));
    }

    [Test]
    public function testLowerEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.lowerEntry(e3.getKey()), e2));
        assertTrue(ObjectUtil.equals(navigableMap.lowerEntry(e2.getKey()), e1));
    }

    [Test]
    public function testTailNavigableMap():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var tailMapInclusive:NavigableMap = navigableMap.tailNavigableMap(e2.getKey(), true);
        var tailMapExclusive:NavigableMap = navigableMap.tailNavigableMap(e1.getKey(), false);

        assertEquals(tailMapInclusive.size(), 2);
        assertEquals(tailMapExclusive.size(), 2);
        assertEquals(sortedMap.size(), 3);
        assertFalse(tailMapInclusive.containsKey(e1.getKey()));
        assertTrue(tailMapInclusive.containsKey(e2.getKey()));
        assertTrue(tailMapInclusive.containsKey(e3.getKey()));
        assertFalse(tailMapExclusive.containsKey(e1.getKey()));
        assertTrue(tailMapExclusive.containsKey(e2.getKey()));
        assertTrue(tailMapExclusive.containsKey(e3.getKey()));

        var afterFirstString:String     = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        tailMapInclusive.put(beforeLastKey, "some value");

        assertEquals(tailMapInclusive.size(), 3);
        assertEquals(tailMapExclusive.size(), 3);
        assertEquals(sortedMap.size(), 4);
        assertFalse(tailMapInclusive.containsKey(e1.getKey()));
        assertTrue(tailMapInclusive.containsKey(e2.getKey()));
        assertTrue(tailMapInclusive.containsKey(e3.getKey()));
        assertTrue(tailMapInclusive.containsKey(beforeLastKey));
        assertFalse(tailMapExclusive.containsKey(e1.getKey()));
        assertTrue(tailMapExclusive.containsKey(e2.getKey()));
        assertTrue(tailMapExclusive.containsKey(e3.getKey()));
        assertTrue(tailMapExclusive.containsKey(beforeLastKey));
        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(beforeLastKey));

        tailMapExclusive.put(afterFirstKey, "some other value");

        assertEquals(tailMapInclusive.size(), 3);
        assertEquals(tailMapExclusive.size(), 4);
        assertEquals(sortedMap.size(), 5);
        assertFalse(tailMapInclusive.containsKey(e1.getKey()));
        assertTrue(tailMapInclusive.containsKey(e2.getKey()));
        assertTrue(tailMapInclusive.containsKey(e3.getKey()));
        assertTrue(tailMapInclusive.containsKey(beforeLastKey));
        assertFalse(tailMapInclusive.containsKey(afterFirstKey));
        assertFalse(tailMapExclusive.containsKey(e1.getKey()));
        assertTrue(tailMapExclusive.containsKey(e2.getKey()));
        assertTrue(tailMapExclusive.containsKey(e3.getKey()));
        assertTrue(tailMapExclusive.containsKey(beforeLastKey));
        assertTrue(tailMapExclusive.containsKey(afterFirstKey));
        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(afterFirstKey));
        assertTrue(sortedMap.containsKey(beforeLastKey));
    }

    [Test]
    public function testDescendingNavigableMap():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var descendingNavigableMap:NavigableMap = navigableMap.descendingNavigableMap();

        var descendingIt:Iterator = descendingNavigableMap.entrySet().iterator();

        var descendingE1:MapEntry = descendingIt.next();
        var descendingE2:MapEntry = descendingIt.next();
        var descendingE3:MapEntry = descendingIt.next();

        assertFalse(descendingIt.hasNext());

        assertTrue(ObjectUtil.equals(e1, descendingE3));
        assertTrue(ObjectUtil.equals(e2, descendingE2));
        assertTrue(ObjectUtil.equals(e3, descendingE1));

        var afterFirstString:String     = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        navigableMap.put(afterFirstKey, "value");
        descendingNavigableMap.put(beforeLastKey, "other value");

        var otherIt:Iterator = navigableMap.entrySet().iterator();

        var otherE1:MapEntry    = otherIt.next();
        var afterE1:MapEntry    = otherIt.next();
        var otherE2:MapEntry    = otherIt.next();
        var beforeE3:MapEntry   = otherIt.next();
        var otherE3:MapEntry    = otherIt.next();

        assertFalse(otherIt.hasNext());

        var otherDescendingIt:Iterator = descendingNavigableMap.entrySet().iterator();

        var otherDescendingE1:MapEntry  = otherDescendingIt.next();
        var afterDescendingE1:MapEntry  = otherDescendingIt.next();
        var otherDescendingE2:MapEntry  = otherDescendingIt.next();
        var beforeDescendingE3:MapEntry = otherDescendingIt.next();
        var otherDescendingE3:MapEntry  = otherDescendingIt.next();

        assertFalse(otherDescendingIt.hasNext());

        assertTrue(ObjectUtil.equals(otherE1, otherDescendingE3));
        assertTrue(ObjectUtil.equals(afterE1, beforeDescendingE3));
        assertTrue(ObjectUtil.equals(otherE2, otherDescendingE2));
        assertTrue(ObjectUtil.equals(beforeE3, afterDescendingE1));
        assertTrue(ObjectUtil.equals(otherE3, otherDescendingE1));
    }

    [Test]
    public function testLastEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.lastEntry(), e3));
    }

    [Test]
    public function testPollLastEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.pollLastEntry(), e3));
        assertTrue(ObjectUtil.equals(navigableMap.pollLastEntry(), e2));
        assertTrue(ObjectUtil.equals(navigableMap.pollLastEntry(), e1));
        assertTrue(ObjectUtil.equals(navigableMap.pollLastEntry(), null));
    }

    [Test]
    public function testLowerKey():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.lowerKey(e3.getKey()), e2.getKey()));
        assertTrue(ObjectUtil.equals(navigableMap.lowerKey(e2.getKey()), e1.getKey()));
    }

    [Test]
    public function testPollFirstEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.pollFirstEntry(), e1));
        assertTrue(ObjectUtil.equals(navigableMap.pollFirstEntry(), e2));
        assertTrue(ObjectUtil.equals(navigableMap.pollFirstEntry(), e3));
        assertTrue(ObjectUtil.equals(navigableMap.pollFirstEntry(), null));
    }

    [Test]
    public function testCeilingKey():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var beforeFirstString:String = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1);
        var beforeFirstKey:TestSubject = new TestSubject(beforeFirstString);

        var afterFirstString:String = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject = new TestSubject(afterFirstString);

        assertTrue(ObjectUtil.equals(navigableMap.ceilingKey(beforeFirstKey), e1.getKey()));
        assertTrue(ObjectUtil.equals(navigableMap.ceilingKey(afterFirstKey), e2.getKey()));
        assertTrue(ObjectUtil.equals(navigableMap.ceilingKey(e1.getKey()), e1.getKey()));
    }

    [Test]
    public function testDescendingNavigableKeySet():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var descendingNavigableKeySet:NavigableSet = navigableMap.descendingNavigableKeySet();

        var keyIt:Iterator = descendingNavigableKeySet.iterator();

        var k1:TestSubject = keyIt.next();
        var k2:TestSubject = keyIt.next();
        var k3:TestSubject = keyIt.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(e1.getKey(), k3));
        assertTrue(ObjectUtil.equals(e2.getKey(), k2));
        assertTrue(ObjectUtil.equals(e3.getKey(), k1));

        var afterFirstString:String     = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var beforeLastString:String     = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "A";
        var beforeLastKey:TestSubject   = new TestSubject(beforeLastString);

        navigableMap.put(afterFirstKey, "value");
        navigableMap.put(beforeLastKey, "other value");

        var otherIt:Iterator = navigableMap.entrySet().iterator();

        var otherE1:MapEntry    = otherIt.next();
        var afterE1:MapEntry    = otherIt.next();
        var otherE2:MapEntry    = otherIt.next();
        var beforeE3:MapEntry   = otherIt.next();
        var otherE3:MapEntry    = otherIt.next();

        assertFalse(otherIt.hasNext());

        var otherKeyIt:Iterator = descendingNavigableKeySet.iterator();

        var otherK1:TestSubject     = otherKeyIt.next();
        var afterK1:TestSubject     = otherKeyIt.next();
        var otherK2:TestSubject     = otherKeyIt.next();
        var beforeK3:TestSubject    = otherKeyIt.next();
        var otherK3:TestSubject     = otherKeyIt.next();

        assertFalse(otherKeyIt.hasNext());

        assertTrue(ObjectUtil.equals(otherE1.getKey(), otherK3));
        assertTrue(ObjectUtil.equals(otherE2.getKey(), otherK2));
        assertTrue(ObjectUtil.equals(otherE3.getKey(), otherK1));
        assertTrue(ObjectUtil.equals(afterE1.getKey(), beforeK3));
        assertTrue(ObjectUtil.equals(beforeE3.getKey(), afterK1));
    }

    [Test]
    public function testCeilingEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var beforeFirstString:String = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1);
        var beforeFirstKey:TestSubject = new TestSubject(beforeFirstString);

        var afterFirstString:String = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject = new TestSubject(afterFirstString);

        assertTrue(ObjectUtil.equals(navigableMap.ceilingEntry(beforeFirstKey), e1));
        assertTrue(ObjectUtil.equals(navigableMap.ceilingEntry(afterFirstKey), e2));
        assertTrue(ObjectUtil.equals(navigableMap.ceilingEntry(e1.getKey()), e1));
    }

    [Test]
    public function testHigherKey():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(navigableMap.higherKey(e1.getKey()), e2.getKey()));
        assertTrue(ObjectUtil.equals(navigableMap.higherKey(e2.getKey()), e3.getKey()));
    }

    [Test]
    public function testSubNavigableMap():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var subMapInclusive:NavigableMap = navigableMap.subNavigableMap(e2.getKey(), true, e3.getKey(), false);
        var subMapExclusive:NavigableMap = navigableMap.subNavigableMap(e1.getKey(), false, e2.getKey(), true);

        assertEquals(subMapInclusive.size(), 1);
        assertEquals(subMapExclusive.size(), 1);
        assertEquals(navigableMap.size(), 3);
        assertFalse(subMapInclusive.containsKey(e1.getKey()));
        assertTrue(subMapInclusive.containsKey(e2.getKey()));
        assertFalse(subMapInclusive.containsKey(e3.getKey()));
        assertFalse(subMapExclusive.containsKey(e1.getKey()));
        assertTrue(subMapExclusive.containsKey(e2.getKey()));
        assertFalse(subMapExclusive.containsKey(e3.getKey()));

        var afterFirstString:String    = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject  = new TestSubject(afterFirstString);
        var beforeLastString:String      = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "A";
        var beforeLastKey:TestSubject    = new TestSubject(beforeLastString);

        subMapInclusive.put(beforeLastKey, "some value");

        assertEquals(subMapInclusive.size(), 2);
        assertEquals(subMapExclusive.size(), 1);
        assertEquals(navigableMap.size(), 4);
        assertFalse(subMapInclusive.containsKey(e1.getKey()));
        assertTrue(subMapInclusive.containsKey(e2.getKey()));
        assertFalse(subMapInclusive.containsKey(e3.getKey()));
        assertTrue(subMapInclusive.containsKey(beforeLastKey));
        assertFalse(subMapExclusive.containsKey(e1.getKey()));
        assertTrue(subMapExclusive.containsKey(e2.getKey()));
        assertFalse(subMapExclusive.containsKey(e3.getKey()));
        assertFalse(subMapExclusive.containsKey(beforeLastKey));
        assertTrue(navigableMap.containsKey(e1.getKey()));
        assertTrue(navigableMap.containsKey(e2.getKey()));
        assertTrue(navigableMap.containsKey(e3.getKey()));
        assertTrue(navigableMap.containsKey(beforeLastKey));

        navigableMap.put(afterFirstKey, "some other value");

        assertEquals(subMapInclusive.size(), 2);
        assertEquals(subMapExclusive.size(), 2);
        assertEquals(navigableMap.size(), 5);
        assertFalse(subMapInclusive.containsKey(e1.getKey()));
        assertTrue(subMapInclusive.containsKey(e2.getKey()));
        assertFalse(subMapInclusive.containsKey(e3.getKey()));
        assertTrue(subMapInclusive.containsKey(beforeLastKey));
        assertFalse(subMapInclusive.containsKey(afterFirstKey));
        assertFalse(subMapExclusive.containsKey(e1.getKey()));
        assertTrue(subMapExclusive.containsKey(e2.getKey()));
        assertFalse(subMapExclusive.containsKey(e3.getKey()));
        assertFalse(subMapExclusive.containsKey(beforeLastKey));
        assertTrue(subMapExclusive.containsKey(afterFirstKey));
        assertTrue(navigableMap.containsKey(e1.getKey()));
        assertTrue(navigableMap.containsKey(e2.getKey()));
        assertTrue(navigableMap.containsKey(e3.getKey()));
        assertTrue(navigableMap.containsKey(beforeLastKey));
        assertTrue(navigableMap.containsKey(afterFirstKey));
    }

    [Test]
    public function testFloorKey():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var beforeSecondString:String = TestSubject(e2.getKey()).str.substr(0, TestSubject(e2.getKey()).str.length - 1);
        var beforeSecondKey:TestSubject = new TestSubject(beforeSecondString);

        var afterSecondString:String = TestSubject(e2.getKey()).str.substr(0, TestSubject(e2.getKey()).str.length - 1) + "z";
        var afterSecondKey:TestSubject = new TestSubject(afterSecondString);

        assertTrue(ObjectUtil.equals(navigableMap.floorEntry(beforeSecondKey), e1));
        assertTrue(ObjectUtil.equals(navigableMap.floorEntry(afterSecondKey), e2));
        assertTrue(ObjectUtil.equals(navigableMap.floorEntry(e1.getKey()), e1));
    }

    [Test]
    public function testFloorEntry():void {
        var it:Iterator = navigableMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var beforeSecondString:String = TestSubject(e2.getKey()).str.substr(0, TestSubject(e2.getKey()).str.length - 1);
        var beforeSecondKey:TestSubject = new TestSubject(beforeSecondString);

        var afterSecondString:String = TestSubject(e2.getKey()).str.substr(0, TestSubject(e2.getKey()).str.length - 1) + "z";
        var afterSecondKey:TestSubject = new TestSubject(afterSecondString);

        assertTrue(ObjectUtil.equals(navigableMap.floorEntry(beforeSecondKey), e1));
        assertTrue(ObjectUtil.equals(navigableMap.floorEntry(afterSecondKey), e2));
        assertTrue(ObjectUtil.equals(navigableMap.floorEntry(e1.getKey()), e1));
    }

    [Test]
    override public function testTailMap():void {
        super.testTailMap();
    }

    [Test]
    override public function testSubMap():void {
        super.testSubMap();
    }

    [Test]
    override public function testLastKey():void {
        super.testLastKey();
    }

    [Test]
    override public function testFirstKey():void {
        super.testFirstKey();
    }

    [Test]
    override public function testComparator():void {
        super.testComparator();
    }

    [Test]
    override public function testHeadMap():void {
        super.testHeadMap();
    }

    [Test]
    override public function testPutAll():void {
        super.testPutAll();
    }

    [Test]
    override public function testRemoveKey():void {
        super.testRemoveKey();
    }

    [Test]
    override public function testContainsValue():void {
        super.testContainsValue();
    }

    [Test]
    override public function testEntrySet():void {
        super.testEntrySet();
    }

    [Test]
    override public function testGet():void {
        super.testGet();
    }

    [Test]
    override public function testPut():void {
        super.testPut();
    }

    [Test]
    override public function testContainsKey():void {
        super.testContainsKey();
    }

    [Test]
    override public function testSize():void {
        super.testSize();
    }

    [Test]
    override public function testValues():void {
        super.testValues();
    }

    [Test]
    override public function testClear():void {
        super.testClear();
    }

    [Test]
    override public function testIsEmpty():void {
        super.testIsEmpty();
    }

    [Test]
    override public function testKeySet():void {
        super.testKeySet();
    }
}

}
