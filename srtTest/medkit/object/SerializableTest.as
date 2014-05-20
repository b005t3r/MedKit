/**
 * User: booster
 * Date: 20/05/14
 * Time: 14:31
 */
package medkit.object {
import medkit.object.test.SimpleSerializable;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class SerializableTest {
    private var input:ObjectInputStream;
    private var output:ObjectOutputStream;

    public function SerializableTest() {
    }

    [Before]
    public function setUp():void {
        output = new ObjectOutputStream();
        input = new ObjectInputStream(output.jsonData);
    }

    [After]
    public function tearDown():void {
        input = null;
        output = null;
    }

    [Test]
    public function testSerializeBoolean():void {
        var a:Boolean = true;

        output.writeBoolean(a, "a");

        assertEquals(a, output.jsonData.globalKeys["a"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var v:Boolean = input.readBoolean("a");

        assertEquals(a, v);

        var b:Boolean = false;

        output.writeBoolean(b, "b");

        assertEquals(b, output.jsonData.globalKeys["b"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var z:Boolean = input.readBoolean("b");

        assertEquals(b, z);
    }

    [Test]
    public function testSerializeUnsignedInt():void {
        var a:uint = 55;

        output.writeUnsignedInt(a, "a");

        assertEquals(a, output.jsonData.globalKeys["a"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var v:uint = input.readUnsignedInt("a");

        assertEquals(a, v);

        var b:uint = 0xFFFFFFFF;

        output.writeUnsignedInt(b, "b");

        assertEquals(b, output.jsonData.globalKeys["b"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var z:uint = input.readUnsignedInt("b");

        assertEquals(b, z);
    }

    [Test]
    public function testSerializeString():void {
        var a:String = "Siala baba mak";

        output.writeString(a, "a");

        assertEquals(a, output.jsonData.globalKeys["a"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var v:String = input.readString("a");

        assertEquals(a, v);

        var b:String = "nie wiedziala jak";

        output.writeString(b, "b");

        assertEquals(b, output.jsonData.globalKeys["b"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var z:String = input.readString("b");

        assertEquals(b, z);
    }

    [Test]
    public function testSerializeInt():void {
        var a:int = -55;

        output.writeInt(a, "a");

        assertEquals(a, output.jsonData.globalKeys["a"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var v:int = input.readInt("a");

        assertEquals(a, v);

        var b:int = 0xFFFFFFFF;

        output.writeInt(b, "b");

        assertEquals(b, output.jsonData.globalKeys["b"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var z:int = input.readInt("b");

        assertEquals(b, z);
    }

    [Test]
    public function testSerializeNumber():void {
        var a:Number = -52.23424534;

        output.writeNumber(a, "a");

        assertEquals(a, output.jsonData.globalKeys["a"]);
        assertEquals(0, output.jsonData.serializedObjects.length);

        var v:Number = input.readNumber("a");

        assertEquals(a, v);

        var b:Number = NaN;

        output.writeNumber(b, "b");

        assertTrue(null != output.jsonData.globalKeys["b"]);
        assertTrue(output.jsonData.globalKeys["b"] != output.jsonData.globalKeys["b"]); // isNaN
        assertEquals(0, output.jsonData.serializedObjects.length);

        var z:Number = input.readNumber("b");

        assertTrue(b != b && z != z && b != z); // isNaN
    }

    [Test]
    public function testSerializeObject():void {
        var a:SimpleSerializable = new SimpleSerializable("simple", 5);

        output.writeObject(a, "a");

        assertFalse(a == output.jsonData.globalKeys["a"]);
        assertEquals(1, output.jsonData.serializedObjects.length);

        var v:Object = input.readObject("a");

        assertFalse(a == v);
        assertTrue(ObjectUtil.equals(a, v));

        var b:SimpleSerializable = null;

        output.writeObject(b, "b");

        assertTrue(output.jsonData.globalKeys["b"].hasOwnProperty("thisIsANullObject"));
        assertEquals(1, output.jsonData.serializedObjects.length);

        var z:Object = input.readObject("b");

        assertTrue(b == z);
    }
}
}
