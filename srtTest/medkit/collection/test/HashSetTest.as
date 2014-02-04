/**
 * User: booster
 * Date: 12/9/12
 * Time: 12:09
 */

package medkit.collection.test {

import medkit.collection.HashSet;
import medkit.collection.test.base.SetTest;

public class HashSetTest extends SetTest {
    [Before]
    public function setUp():void {
        collection = set = new HashSet();

        addContent();
    }

    [After]
    public function tearDown():void {
        collection = set = null;
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
