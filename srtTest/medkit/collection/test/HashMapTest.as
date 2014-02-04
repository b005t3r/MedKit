/**
 * User: booster
 * Date: 11/18/12
 * Time: 13:07
 */

package medkit.collection.test {
import medkit.collection.*;
import medkit.collection.test.base.MapTest;

public class HashMapTest extends MapTest {
    [Before]
    public function setUp():void {
        map = new HashMap();

        addContent();
    }

    [After]
    public function tearDown():void {
        map = null;
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
