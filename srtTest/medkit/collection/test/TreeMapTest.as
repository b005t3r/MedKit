/**
 * User: booster
 * Date: 12/18/12
 * Time: 21:14
 */

package medkit.collection.test {

import medkit.collection.SortedMap;
import medkit.collection.TreeMap;
import medkit.collection.test.base.NavigableMapTest;
import medkit.object.Comparator;

public class TreeMapTest extends NavigableMapTest {
    [Before]
    public function setUp():void {
        map = sortedMap = navigableMap = new TreeMap();

        addContent();
    }

    [After]
    public function tearDown():void {
        map = sortedMap = navigableMap = null;
    }

    [Test]
    override public function testFirstEntry():void {
        super.testFirstEntry();
    }

    [Test]
    override public function testHigherEntry():void {
        super.testHigherEntry();
    }

    [Test]
    override public function testHeadNavigableMap():void {
        super.testHeadNavigableMap();
    }

    [Test]
    override public function testNavigableKeySet():void {
        super.testNavigableKeySet();
    }

    [Test]
    override public function testLowerEntry():void {
        super.testLowerEntry();
    }

    [Test]
    override public function testTailNavigableMap():void {
        super.testTailNavigableMap();
    }

    [Test]
    override public function testDescendingNavigableMap():void {
        super.testDescendingNavigableMap();
    }

    [Test]
    override public function testLastEntry():void {
        super.testLastEntry();
    }

    [Test]
    override public function testPollLastEntry():void {
        super.testPollLastEntry();
    }

    [Test]
    override public function testLowerKey():void {
        super.testLowerKey();
    }

    [Test]
    override public function testPollFirstEntry():void {
        super.testPollFirstEntry();
    }

    [Test]
    override public function testCeilingKey():void {
        super.testCeilingKey();
    }

    [Test]
    override public function testDescendingNavigableKeySet():void {
        super.testDescendingNavigableKeySet();
    }

    [Test]
    override public function testCeilingEntry():void {
        super.testCeilingEntry();
    }

    [Test]
    override public function testHigherKey():void {
        super.testHigherKey();
    }

    [Test]
    override public function testSubNavigableMap():void {
        super.testSubNavigableMap();
    }

    [Test]
    override public function testFloorKey():void {
        super.testFloorKey();
    }

    [Test]
    override public function testFloorEntry():void {
        super.testFloorEntry();
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

    override protected function createSortedMap(comparator:Comparator):SortedMap {
        return new TreeMap(comparator);
    }
}

}
