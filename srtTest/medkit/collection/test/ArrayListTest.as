/**
 * User: booster
 * Date: 12/8/12
 * Time: 11:36
 */

package medkit.collection.test {

import medkit.collection.ArrayList;
import medkit.collection.test.base.ListTest;

public class ArrayListTest extends ListTest {
    [Before]
    public function setUp():void {
        collection = list = new ArrayList();

        addContent();
    }

    [After]
    public function tearDown():void {
        collection = list = null;
    }

    [Test]
    override public function testRemoveAt():void {
        super.testRemoveAt();
    }

    [Test]
    override public function testSet():void {
        super.testSet();
    }

    [Test]
    override public function testAddAt():void {
        super.testAddAt();
    }

    [Test]
    override public function testListIterator():void {
        super.testListIterator();
    }

    [Test]
    override public function testGet():void {
        super.testGet();
    }

    [Test]
    override public function testAddAllAt():void {
        super.testAddAllAt();
    }

    [Test]
    override public function testLastIndexOf():void {
        super.testLastIndexOf();
    }

    [Test]
    override public function testIndexOf():void {
        super.testIndexOf();
    }

    [Test]
    override public function testRemoveRange():void {
        super.testRemoveRange();
    }

    [Test]
    override public function testSubList():void {
        super.testSubList();
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
