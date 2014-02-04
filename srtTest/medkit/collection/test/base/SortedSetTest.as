/**
 * User: booster
 * Date: 12/22/12
 * Time: 13:49
 */

package medkit.collection.test.base {

import medkit.collection.Collections;
import medkit.collection.SortedSet;
import medkit.collection.TestSubject;
import medkit.collection.TestSubjectComparator;
import medkit.collection.iterator.Iterator;
import medkit.object.Comparator;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertNull;
import org.flexunit.asserts.assertTrue;

public class SortedSetTest extends SetTest {
    protected var sortedSet:SortedSet;

    [Test]
    public function testComparator():void {
        assertNull(sortedSet.comparator());

        var cmp:Comparator = new TestSubjectComparator();
        var newSortedMap:SortedSet = createSortedSet(cmp);

        assertTrue(newSortedMap.comparator() === cmp);

        newSortedMap.addAll(sortedSet);

        var it:Iterator = newSortedMap.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(cmp.compare(e1, e2) < 0);
        assertTrue(cmp.compare(e1, e3) < 0);
        assertTrue(cmp.compare(e2, e3) < 0);

        assertTrue(cmp.compare(e1, e1) == 0);
        assertTrue(cmp.compare(e2, e2) == 0);
        assertTrue(cmp.compare(e3, e3) == 0);

        assertTrue(cmp.compare(e2, e1) > 0);
        assertTrue(cmp.compare(e3, e1) > 0);
        assertTrue(cmp.compare(e3, e2) > 0);

        var revCmp:Comparator = Collections.reverseOrder(cmp);
        var revNewSortedSet:SortedSet = createSortedSet(revCmp);

        assertTrue(revNewSortedSet.comparator() === revCmp);

        revNewSortedSet.addAll(sortedSet);

        var revIt:Iterator = revNewSortedSet.iterator();

        var revE1:TestSubject = revIt.next();
        var revE2:TestSubject = revIt.next();
        var revE3:TestSubject = revIt.next();

        assertFalse(revIt.hasNext());

        assertTrue(revCmp.compare(revE1, revE2) < 0);
        assertTrue(revCmp.compare(revE1, revE3) < 0);
        assertTrue(revCmp.compare(revE2, revE3) < 0);

        assertTrue(revCmp.compare(revE1, revE1) == 0);
        assertTrue(revCmp.compare(revE2, revE2) == 0);
        assertTrue(revCmp.compare(revE3, revE3) == 0);

        assertTrue(revCmp.compare(revE2, revE1) > 0);
        assertTrue(revCmp.compare(revE3, revE1) > 0);
        assertTrue(revCmp.compare(revE3, revE2) > 0);

        assertTrue(ObjectUtil.equals(e1, revE3));
        assertTrue(ObjectUtil.equals(e2, revE2));
        assertTrue(ObjectUtil.equals(e3, revE1));
    }

    [Test]
    public function testTailSet():void {
        var it:Iterator = sortedSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var tailSet:SortedSet = sortedSet.tailSet(e2);

        assertEquals(tailSet.size(), 2);
        assertEquals(sortedSet.size(), 3);
        assertFalse(tailSet.contains(e1));
        assertTrue(tailSet.contains(e2));
        assertTrue(tailSet.contains(e3));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var afterLastString:String      = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "z";
        var afterLastKey:TestSubject    = new TestSubject(afterLastString);

        tailSet.add(afterLastKey);

        assertEquals(tailSet.size(), 3);
        assertEquals(sortedSet.size(), 4);
        assertFalse(tailSet.contains(e1));
        assertTrue(tailSet.contains(e2));
        assertTrue(tailSet.contains(e3));
        assertTrue(tailSet.contains(afterLastKey));

        assertTrue(sortedSet.contains(e1));
        assertTrue(sortedSet.contains(e2));
        assertTrue(sortedSet.contains(e3));
        assertTrue(sortedSet.contains(afterLastKey));

        sortedSet.add(afterFirstKey);

        assertEquals(tailSet.size(), 3);
        assertEquals(sortedSet.size(), 5);
        assertFalse(tailSet.contains(e1));
        assertTrue(tailSet.contains(e2));
        assertTrue(tailSet.contains(e3));
        assertFalse(tailSet.contains(afterFirstKey));
        assertTrue(tailSet.contains(afterLastKey));

        assertTrue(sortedSet.contains(e1));
        assertTrue(sortedSet.contains(e2));
        assertTrue(sortedSet.contains(e3));
        assertTrue(sortedSet.contains(afterFirstKey));
        assertTrue(sortedSet.contains(afterLastKey));
    }

    [Test]
    public function testSubSet():void {
        var it:Iterator = sortedSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var subSet:SortedSet = sortedSet.subSet(e1, e3);

        assertEquals(subSet.size(), 2);
        assertEquals(sortedSet.size(), 3);
        assertTrue(subSet.contains(e1));
        assertTrue(subSet.contains(e2));
        assertFalse(subSet.contains(e3));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var afterLastString:String      = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "z";
        var afterLastKey:TestSubject    = new TestSubject(afterLastString);

        subSet.add(afterFirstKey);

        assertEquals(subSet.size(), 3);
        assertEquals(sortedSet.size(), 4);
        assertTrue(subSet.contains(e1));
        assertTrue(subSet.contains(e2));
        assertFalse(subSet.contains(e3));
        assertTrue(subSet.contains(afterFirstKey));

        assertTrue(sortedSet.contains(e1));
        assertTrue(sortedSet.contains(e2));
        assertTrue(sortedSet.contains(e3));
        assertTrue(sortedSet.contains(afterFirstKey));

        sortedSet.add(afterLastKey);

        assertEquals(subSet.size(), 3);
        assertEquals(sortedSet.size(), 5);
        assertTrue(subSet.contains(e1));
        assertTrue(subSet.contains(e2));
        assertFalse(subSet.contains(e3));
        assertTrue(subSet.contains(afterFirstKey));
        assertFalse(subSet.contains(afterLastKey));

        assertTrue(sortedSet.contains(e1));
        assertTrue(sortedSet.contains(e2));
        assertTrue(sortedSet.contains(e3));
        assertTrue(sortedSet.contains(afterFirstKey));
        assertTrue(sortedSet.contains(afterLastKey));
    }

    [Test]
    public function testLast():void {
        var it:Iterator = sortedSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(sortedSet.last(), e3));
    }

    [Test]
    public function testFirst():void {
        var it:Iterator = sortedSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        assertTrue(ObjectUtil.equals(sortedSet.first(), e1));
    }

    [Test]
    public function testHeadSet():void {
        var it:Iterator = sortedSet.iterator();

        var e1:TestSubject = it.next();
        var e2:TestSubject = it.next();
        var e3:TestSubject = it.next();

        assertFalse(it.hasNext());

        var headSet:SortedSet = sortedSet.headSet(e3);

        assertEquals(headSet.size(), 2);
        assertEquals(sortedSet.size(), 3);
        assertTrue(headSet.contains(e1));
        assertTrue(headSet.contains(e2));
        assertFalse(headSet.contains(e3));

        var afterFirstString:String     = TestSubject(e1).str.substr(0, TestSubject(e1).str.length - 1) + "z";
        var afterFirstKey:TestSubject   = new TestSubject(afterFirstString);
        var afterLastString:String      = TestSubject(e3).str.substr(0, TestSubject(e3).str.length - 1) + "z";
        var afterLastKey:TestSubject    = new TestSubject(afterLastString);

        headSet.add(afterFirstKey);

        assertEquals(headSet.size(), 3);
        assertEquals(sortedSet.size(), 4);
        assertTrue(headSet.contains(e1));
        assertTrue(headSet.contains(e2));
        assertFalse(headSet.contains(e3));
        assertTrue(headSet.contains(afterFirstKey));

        assertTrue(sortedSet.contains(e1));
        assertTrue(sortedSet.contains(e2));
        assertTrue(sortedSet.contains(e3));
        assertTrue(sortedSet.contains(afterFirstKey));

        sortedSet.add(afterLastKey);

        assertEquals(headSet.size(), 3);
        assertEquals(sortedSet.size(), 5);
        assertTrue(headSet.contains(e1));
        assertTrue(headSet.contains(e2));
        assertFalse(headSet.contains(e3));
        assertTrue(headSet.contains(afterFirstKey));
        assertFalse(headSet.contains(afterLastKey));

        assertTrue(sortedSet.contains(e1));
        assertTrue(sortedSet.contains(e2));
        assertTrue(sortedSet.contains(e3));
        assertTrue(sortedSet.contains(afterFirstKey));
        assertTrue(sortedSet.contains(afterLastKey));
    }

    protected function createSortedSet(comparator:Comparator):SortedSet {
        throw new DefinitionError("this method must be implemented");
    }
}

}
