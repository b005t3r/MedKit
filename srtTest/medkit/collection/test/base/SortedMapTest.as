/**
 * User: booster
 * Date: 12/18/12
 * Time: 21:08
 */

package medkit.collection.test.base {

import medkit.collection.Collections;
import medkit.collection.MapEntry;
import medkit.collection.SortedMap;
import medkit.collection.TestSubject;
import medkit.collection.TestSubjectComparator;
import medkit.collection.iterator.Iterator;
import medkit.object.Comparator;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertNull;
import org.flexunit.asserts.assertTrue;

public class SortedMapTest extends MapTest {
    protected var sortedMap:SortedMap;

    [Test]
    public function testTailMap():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var tailMap:SortedMap = sortedMap.tailMap(e2.getKey());

        assertEquals(tailMap.size(), 2);
        assertEquals(sortedMap.size(), 3);
        assertFalse(tailMap.containsKey(e1.getKey()));
        assertTrue(tailMap.containsKey(e2.getKey()));
        assertTrue(tailMap.containsKey(e3.getKey()));

        var str:String = TestSubject(e2.getKey()).str.substr(0, TestSubject(e2.getKey()).str.length - 1) + "z";

        var newKey:TestSubject = new TestSubject(str);

        tailMap.put(newKey, "some value");

        assertEquals(tailMap.size(), 3);
        assertEquals(sortedMap.size(), 4);
        assertFalse(tailMap.containsKey(e1.getKey()));
        assertTrue(tailMap.containsKey(e2.getKey()));
        assertTrue(tailMap.containsKey(e3.getKey()));
        assertTrue(tailMap.containsKey(newKey));

        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(newKey));
    }

    [Test]
    public function testSubMap():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var subMap:SortedMap = sortedMap.subMap(e2.getKey(), e3.getKey());

        assertEquals(subMap.size(), 1);
        assertEquals(sortedMap.size(), 3);
        assertFalse(subMap.containsKey(e1.getKey()));
        assertTrue(subMap.containsKey(e2.getKey()));
        assertFalse(subMap.containsKey(e3.getKey()));

        var str:String = TestSubject(e2.getKey()).str.substr(0, TestSubject(e2.getKey()).str.length - 1) + "z";

        var newKey:TestSubject = new TestSubject(str);

        subMap.put(newKey, "some value");

        assertEquals(subMap.size(), 2);
        assertEquals(sortedMap.size(), 4);
        assertFalse(subMap.containsKey(e1.getKey()));
        assertTrue(subMap.containsKey(e2.getKey()));
        assertFalse(subMap.containsKey(e3.getKey()));
        assertTrue(subMap.containsKey(newKey));

        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(newKey));
    }

    [Test]
    public function testHeadMap():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        var headMap:SortedMap = sortedMap.headMap(e3.getKey());

        assertEquals(headMap.size(), 2);
        assertEquals(sortedMap.size(), 3);
        assertTrue(headMap.containsKey(e1.getKey()));
        assertTrue(headMap.containsKey(e2.getKey()));
        assertFalse(headMap.containsKey(e3.getKey()));

        var afterFirstString:String     = TestSubject(e1.getKey()).str.substr(0, TestSubject(e1.getKey()).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var afterLastString:String      = TestSubject(e3.getKey()).str.substr(0, TestSubject(e3.getKey()).str.length - 1) + "z";
        var afterLastKey:TestSubject    = new TestSubject(afterLastString);

        headMap.put(afterFirstKey, "some value");

        assertEquals(headMap.size(), 3);
        assertEquals(sortedMap.size(), 4);
        assertTrue(headMap.containsKey(e1.getKey()));
        assertTrue(headMap.containsKey(e2.getKey()));
        assertFalse(headMap.containsKey(e3.getKey()));
        assertTrue(headMap.containsKey(afterFirstKey));

        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(afterFirstKey));

        sortedMap.put(afterLastKey, "some other value");

        assertEquals(headMap.size(), 3);
        assertEquals(sortedMap.size(), 5);
        assertTrue(headMap.containsKey(e1.getKey()));
        assertTrue(headMap.containsKey(e2.getKey()));
        assertFalse(headMap.containsKey(e3.getKey()));
        assertTrue(headMap.containsKey(afterFirstKey));
        assertFalse(headMap.containsKey(afterLastKey));

        assertTrue(sortedMap.containsKey(e1.getKey()));
        assertTrue(sortedMap.containsKey(e2.getKey()));
        assertTrue(sortedMap.containsKey(e3.getKey()));
        assertTrue(sortedMap.containsKey(afterFirstKey));
        assertTrue(sortedMap.containsKey(afterLastKey));
    }

    [Test]
    public function testLastKey():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(e3.getKey() === sortedMap.lastKey());
    }

    [Test]
    public function testFirstKey():void {
        var it:Iterator = sortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(e1.getKey() === sortedMap.firstKey());
    }

    [Test]
    public function testComparator():void {
        assertNull(sortedMap.comparator());

        var cmp:Comparator = new TestSubjectComparator();
        var newSortedMap:SortedMap = createSortedMap(cmp);

        assertTrue(newSortedMap.comparator() === cmp);

        newSortedMap.putAll(sortedMap);

        var it:Iterator = newSortedMap.entrySet().iterator();

        var e1:MapEntry = it.next();
        var e2:MapEntry = it.next();
        var e3:MapEntry = it.next();

        assertFalse(it.hasNext());

        assertTrue(cmp.compare(e1.getKey(), e2.getKey()) < 0);
        assertTrue(cmp.compare(e1.getKey(), e3.getKey()) < 0);
        assertTrue(cmp.compare(e2.getKey(), e3.getKey()) < 0);

        assertTrue(cmp.compare(e1.getKey(), e1.getKey()) == 0);
        assertTrue(cmp.compare(e2.getKey(), e2.getKey()) == 0);
        assertTrue(cmp.compare(e3.getKey(), e3.getKey()) == 0);

        assertTrue(cmp.compare(e2.getKey(), e1.getKey()) > 0);
        assertTrue(cmp.compare(e3.getKey(), e1.getKey()) > 0);
        assertTrue(cmp.compare(e3.getKey(), e2.getKey()) > 0);

        var revCmp:Comparator = Collections.reverseOrder(cmp);
        var revNewSortedMap:SortedMap = createSortedMap(revCmp);

        assertTrue(revNewSortedMap.comparator() === revCmp);

        revNewSortedMap.putAll(sortedMap);

        var revIt:Iterator = revNewSortedMap.entrySet().iterator();

        var revE1:MapEntry = revIt.next();
        var revE2:MapEntry = revIt.next();
        var revE3:MapEntry = revIt.next();

        assertFalse(revIt.hasNext());

        assertTrue(revCmp.compare(revE1.getKey(), revE2.getKey()) < 0);
        assertTrue(revCmp.compare(revE1.getKey(), revE3.getKey()) < 0);
        assertTrue(revCmp.compare(revE2.getKey(), revE3.getKey()) < 0);

        assertTrue(revCmp.compare(revE1.getKey(), revE1.getKey()) == 0);
        assertTrue(revCmp.compare(revE2.getKey(), revE2.getKey()) == 0);
        assertTrue(revCmp.compare(revE3.getKey(), revE3.getKey()) == 0);

        assertTrue(revCmp.compare(revE2.getKey(), revE1.getKey()) > 0);
        assertTrue(revCmp.compare(revE3.getKey(), revE1.getKey()) > 0);
        assertTrue(revCmp.compare(revE3.getKey(), revE2.getKey()) > 0);

        assertTrue(ObjectUtil.equals(e1, revE3));
        assertTrue(ObjectUtil.equals(e2, revE2));
        assertTrue(ObjectUtil.equals(e3, revE1));
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

    protected function createSortedMap(comparator:Comparator):SortedMap {
        throw new DefinitionError("this method has to be implemented");
    }
}

}
