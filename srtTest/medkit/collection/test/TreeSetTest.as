/**
 * User: booster
 * Date: 12/22/12
 * Time: 15:46
 */
package medkit.collection.test {
import medkit.collection.*;
import medkit.collection.test.base.NavigableSetTest;
import medkit.object.Comparator;

public class TreeSetTest extends NavigableSetTest {
    [Before]
    public function setUp():void {
        collection = set = sortedSet = navigableSet = new TreeSet();

        addContent();
    }

    [After]
    public function tearDown():void {
        collection = set = sortedSet = navigableSet = null;
    }

    [Test]
    override public function testPollLast():void {
        super.testPollLast();
    }

    [Test]
    override public function testPollFirst():void {
        super.testPollFirst();
    }

    [Test]
    override public function testTailNavigableSet():void {
        super.testTailNavigableSet();
    }

    [Test]
    override public function testSubNavigableSet():void {
        super.testSubNavigableSet();
    }

    [Test]
    override public function testDescendingIterator():void {
        super.testDescendingIterator();
    }

    [Test]
    override public function testHigher():void {
        super.testHigher();
    }

    [Test]
    override public function testCeiling():void {
        super.testCeiling();
    }

    [Test]
    override public function testFloor():void {
        super.testFloor();
    }

    [Test]
    override public function testLower():void {
        super.testLower();
    }

    [Test]
    override public function testDescendingSet():void {
        super.testDescendingSet();
    }

    [Test]
    override public function testHeadNavigableSet():void {
        super.testHeadNavigableSet();
    }

    [Test]
    override public function testComparator():void {
        super.testComparator();
    }

    [Test]
    override public function testTailSet():void {
        super.testTailSet();
    }

    [Test]
    override public function testSubSet():void {
        super.testSubSet();
    }

    [Test]
    override public function testLast():void {
        super.testLast();
    }

    [Test]
    override public function testFirst():void {
        super.testFirst();
    }

    [Test]
    override public function testHeadSet():void {
        super.testHeadSet();
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

    override protected function createSortedSet(comparator:Comparator):SortedSet {
        return new TreeSet(comparator);
    }

    [Test]
    override public function testToString():void {
        super.testToString();
    }
}

}
