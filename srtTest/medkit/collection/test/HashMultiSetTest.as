/**
 * User: booster
 * Date: 19/09/15
 * Time: 13:28
 */
package medkit.collection.test {
import medkit.collection.HashMultiSet;
import medkit.collection.test.base.MultiSetTest;

public class HashMultiSetTest extends MultiSetTest {
    [Before]
    public function setUp():void {
        collection = set = multiSet = new HashMultiSet();

        addContent();
    }

    [After]
    public function tearDown():void {
        collection = set = multiSet = null;
    }

    [Test]
    override public function testAddCount():void {
        super.testAddCount();
    }

    [Test]
    override public function testRemoveCount():void {
        super.testRemoveCount();
    }

    [Test]
    override public function testSetCount():void {
        super.testSetCount();
    }

    [Test]
    override public function testElementCount():void {
        super.testElementCount();
    }

    override protected function addContent():void {
        super.addContent();
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
        super.testContains();
    }

    [Test]
    override public function testToString():void {
        super.testToString();
    }
}
}
