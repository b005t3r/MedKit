/**
 * User: booster
 * Date: 21/05/14
 * Time: 9:28
 */
package medkit.object {
import flash.filesystem.File;
import flash.utils.Dictionary;

import medkit.object.test.ComplexSerializable;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class ComplexSerializableTest {
    private var input:ObjectInputStream;
    private var output:ObjectOutputStream;

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
    public function testTreeStructureString():void {
        var root:ComplexSerializable = new ComplexSerializable("root");
        var siblingLvl1A:ComplexSerializable = new ComplexSerializable("A - Lvl 1", root);
        var siblingLvl1B:ComplexSerializable = new ComplexSerializable("B - Lvl 1", root);
        var siblingLvl1C:ComplexSerializable = new ComplexSerializable("C - Lvl 1", root);
        var siblingLvl2A:ComplexSerializable = new ComplexSerializable("A - Lvl 2", siblingLvl1B);
        var siblingLvl2B:ComplexSerializable = new ComplexSerializable("B - Lvl 2", siblingLvl1B);

        output.writeObject(siblingLvl2A, "lvl2A");

        assertFalse(siblingLvl2A == output.jsonData.globalKeys["a"]);
        assertEquals(3, output.jsonData.serializedObjects.length); // only root, siblingLvl1B and siblingLvl2A saved - others not accessible from siblingLvl2A

        var loadedSiblingLvl2A:ComplexSerializable = input.readObject("lvl2A") as ComplexSerializable;

        assertFalse(loadedSiblingLvl2A == siblingLvl2A);
        assertTrue(ObjectUtil.equals(loadedSiblingLvl2A, siblingLvl2A));

        assertFalse(loadedSiblingLvl2A.other == siblingLvl2A.other);
        assertTrue(ObjectUtil.equals(loadedSiblingLvl2A.other, siblingLvl2A.other));

        assertFalse(loadedSiblingLvl2A.other.other == siblingLvl2A.other.other);
        assertTrue(ObjectUtil.equals(loadedSiblingLvl2A.other.other, siblingLvl2A.other.other));
    }

    [Test]
    public function testListStructureString():void {
        var a:ComplexSerializable = new ComplexSerializable("a");
        var b:ComplexSerializable = new ComplexSerializable("b", a);
        var c:ComplexSerializable = new ComplexSerializable("c", b);
        var d:ComplexSerializable = new ComplexSerializable("d", c);

        output.writeObject(d, "d");

        assertFalse(d == output.jsonData.globalKeys["d"]);
        assertEquals(4, output.jsonData.serializedObjects.length);

        var loadedD:ComplexSerializable = input.readObject("d") as ComplexSerializable;

        assertFalse(d == loadedD);
        assertTrue(ObjectUtil.equals(d, loadedD));

        assertFalse(d.other == loadedD.other);
        assertTrue(ObjectUtil.equals(d.other, loadedD.other));

        assertFalse(d.other.other == loadedD.other.other);
        assertTrue(ObjectUtil.equals(d.other.other, loadedD.other.other));

        assertFalse(d.other.other.other == loadedD.other.other.other);
        assertTrue(ObjectUtil.equals(d.other.other.other, loadedD.other.other.other));

        assertTrue(d.other.other.other.other == null && loadedD.other.other.other.other == null);
    }

    [Test]
    public function testLoopStructureString():void {
        var a:ComplexSerializable = new ComplexSerializable("a");
        var b:ComplexSerializable = new ComplexSerializable("b", a);
        var c:ComplexSerializable = new ComplexSerializable("c", b);
        var d:ComplexSerializable = new ComplexSerializable("d", c);
        a.other = d;

        output.writeObject(d, "d");

        assertFalse(d == output.jsonData.globalKeys["d"]);
        assertEquals(4, output.jsonData.serializedObjects.length);

        var loadedD:ComplexSerializable = input.readObject("d") as ComplexSerializable;

        assertFalse(d == loadedD);
        assertTrue(ObjectUtil.equals(d, loadedD));

        assertFalse(d.other == loadedD.other);
        assertTrue(ObjectUtil.equals(d.other, loadedD.other));

        assertFalse(d.other.other == loadedD.other.other);
        assertTrue(ObjectUtil.equals(d.other.other, loadedD.other.other));

        assertFalse(d.other.other.other == loadedD.other.other.other);
        assertTrue(ObjectUtil.equals(d.other.other.other, loadedD.other.other.other));

        assertFalse(d.other.other.other.other == loadedD.other.other.other.other);
        assertTrue(ObjectUtil.equals(d.other.other.other.other, loadedD.other.other.other.other));
    }

    [Test]
    public function testComplexStructureString():void {
        var arr:Array = [];
        var dict:Dictionary = new Dictionary();
        var a:ComplexSerializable = new ComplexSerializable("a");
        var b:ComplexSerializable = new ComplexSerializable("a");
        var c:ComplexSerializable = new ComplexSerializable("a");

        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = arr;
        arr[4] = dict;
        arr[5] = "siala baba mak";
        //arr[6] = NaN; // NaN not supported
        arr[6] = 12;

        dict["a"] = a;
        dict["b"] = b;
        dict["c"] = c;
        dict["dict"] = dict;
        dict["arr"] = arr;

        a.other = c;
        c.other = b;
        b.other = c;

        output.writeObject(dict, "dict");

        assertFalse(dict == output.jsonData.globalKeys["dict"]);
        assertEquals(5, output.jsonData.serializedObjects.length);

        var loadedDict:Dictionary = input.readObject("dict") as Dictionary;

        assertFalse(dict == loadedDict);
        //assertTrue(ObjectUtil.equals(dict, loadedDict)); it causes stack overflow for some reason

        var out:ObjectOutputStream = new ObjectOutputStream();
        out.writeObject(loadedDict, "dict");

        var dictString:String = JSON.stringify(output.jsonData);
        var loadedDictString:String = JSON.stringify(out.jsonData);

        // the only way to compare these two
        assertEquals(dictString, loadedDictString);

        var file:File = File.createTempFile();

        output.saveToFile(file);

        var inp:ObjectInputStream = ObjectInputStream.readFromFile(file);
        var fileLoadedDict:Dictionary = inp.readObject("dict") as Dictionary;

        out = new ObjectOutputStream();
        out.writeObject(fileLoadedDict, "dict");

        var fileLoadedDictString:String = JSON.stringify(out.jsonData);

        assertEquals(dictString, fileLoadedDictString);
        assertEquals(loadedDictString, fileLoadedDictString);

        file.deleteFile();
    }
}
}
