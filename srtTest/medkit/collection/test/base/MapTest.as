/**
 * User: booster
 * Date: 12/9/12
 * Time: 12:38
 */

package medkit.collection.test.base {

import medkit.collection.Collection;
import medkit.collection.Map;
import medkit.collection.Set;
import medkit.collection.SimpleMapEntry;
import medkit.collection.TestSubject;
import medkit.object.ObjectUtil;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class MapTest {
    protected var map:Map;
    protected var firstKey:TestSubject;
    protected var secondKey:TestSubject;
    protected var thirdKey:TestSubject;
    protected var valueNumber:Number;
    protected var valueTestSubject:TestSubject;
    protected var valueString:String;

    [Test]
    public function testPutAll():void {
        var clone:Map           = ObjectUtil.clone(map, null);
        var newKey:TestSubject  = new TestSubject("1337");
        var newValue:Number     = 80085;

        clone.removeKey(firstKey);
        clone.put(newKey, newValue);

        map.putAll(clone);

        assertTrue(map.containsKey(newKey));
        assertTrue(map.containsValue(newValue));
        assertFalse(ObjectUtil.equals(map, clone));
        assertEquals(map.size(), 4);
    }

    [Test]
    public function testRemoveKey():void {
        map.removeKey(valueTestSubject);

        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));
        assertTrue(map.containsValue(valueNumber));
        assertTrue(map.containsValue(valueTestSubject));
        assertTrue(map.containsValue(valueString));

        map.removeKey(valueString);

        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));
        assertTrue(map.containsValue(valueNumber));
        assertTrue(map.containsValue(valueTestSubject));
        assertTrue(map.containsValue(valueString));

        map.removeKey(firstKey);

        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));
        assertFalse(map.containsValue(valueNumber));
        assertTrue(map.containsValue(valueTestSubject));
        assertTrue(map.containsValue(valueString));

        map.removeKey(thirdKey);

        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertFalse(map.containsKey(thirdKey));
        assertFalse(map.containsValue(valueNumber));
        assertTrue(map.containsValue(valueTestSubject));
        assertFalse(map.containsValue(valueString));

        map.removeKey(secondKey);

        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertFalse(map.containsKey(thirdKey));
        assertFalse(map.containsValue(valueNumber));
        assertFalse(map.containsValue(valueTestSubject));
        assertFalse(map.containsValue(valueString));
    }

    [Test]
    public function testContainsValue():void {
        assertTrue(map.containsValue(valueNumber));
        assertTrue(map.containsValue(valueTestSubject));
        assertTrue(map.containsValue(valueString));
        assertFalse(map.containsValue(123));
    }

    [Test]
    public function testEntrySet():void {
        var set:Set = map.entrySet();

        assertEquals(set.size(), 3);
        assertEquals(map.size(), 3);

        assertTrue(set.contains(new SimpleMapEntry(firstKey, valueNumber)));
        assertTrue(set.contains(new SimpleMapEntry(secondKey, valueTestSubject)));
        assertTrue(set.contains(new SimpleMapEntry(thirdKey, valueString)));
        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(new SimpleMapEntry(valueTestSubject, secondKey));

        assertTrue(set.contains(new SimpleMapEntry(firstKey, valueNumber)));
        assertTrue(set.contains(new SimpleMapEntry(secondKey, valueTestSubject)));
        assertTrue(set.contains(new SimpleMapEntry(thirdKey, valueString)));
        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(new SimpleMapEntry(firstKey, valueNumber));

        assertFalse(set.contains(new SimpleMapEntry(firstKey, valueNumber)));
        assertTrue(set.contains(new SimpleMapEntry(secondKey, valueTestSubject)));
        assertTrue(set.contains(new SimpleMapEntry(thirdKey, valueString)));
        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(new SimpleMapEntry(firstKey, valueNumber));

        assertFalse(set.contains(new SimpleMapEntry(firstKey, valueNumber)));
        assertTrue(set.contains(new SimpleMapEntry(secondKey, valueTestSubject)));
        assertTrue(set.contains(new SimpleMapEntry(thirdKey, valueString)));
        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        map.removeKey(secondKey);

        assertFalse(set.contains(new SimpleMapEntry(firstKey, valueNumber)));
        assertFalse(set.contains(new SimpleMapEntry(secondKey, valueTestSubject)));
        assertTrue(set.contains(new SimpleMapEntry(thirdKey, valueString)));
        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(new SimpleMapEntry(thirdKey, valueString));

        assertFalse(set.contains(new SimpleMapEntry(firstKey, valueNumber)));
        assertFalse(set.contains(new SimpleMapEntry(secondKey, valueTestSubject)));
        assertFalse(set.contains(new SimpleMapEntry(thirdKey, valueString)));
        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertFalse(map.containsKey(thirdKey));

        assertTrue(map.isEmpty());
        assertTrue(set.isEmpty());

        assertEquals(map.size(), 0);
        assertEquals(set.size(), 0);
    }

    [Test]
    public function testGet():void {
        assertTrue(ObjectUtil.equals(map.get(firstKey), valueNumber));
        assertTrue(ObjectUtil.equals(map.get(secondKey), valueTestSubject));
        assertTrue(ObjectUtil.equals(map.get(thirdKey), valueString));
        assertTrue(ObjectUtil.equals(map.get(new TestSubject("123")), null));
    }

    [Test]
    public function testPut():void {
        map.put(new TestSubject("1337"), 80085);
        assertTrue(ObjectUtil.equals(map.get(firstKey), valueNumber));
        assertTrue(ObjectUtil.equals(map.get(secondKey), valueTestSubject));
        assertTrue(ObjectUtil.equals(map.get(thirdKey), valueString));
        assertTrue(ObjectUtil.equals(map.get(new TestSubject("123")), null));
        assertTrue(ObjectUtil.equals(map.get(new TestSubject("1337")), 80085));

        map.put(firstKey, 1337);
        assertFalse(ObjectUtil.equals(map.get(firstKey), valueNumber));
        assertTrue(ObjectUtil.equals(map.get(firstKey), 1337));
    }

    [Test]
    public function testContainsKey():void {
        assertTrue(map.containsKey(firstKey));
        //assertFalse(map.containsKey(valueString));
        assertTrue(map.containsKey(thirdKey));
        //assertFalse(map.containsKey(valueString));
        assertTrue(map.containsKey(secondKey));
        //assertFalse(map.containsKey(valueTestSubject));
    }

    [Test]
    public function testSize():void {
        assertEquals(map.size(), 3);

        map.removeKey(firstKey);

        assertEquals(map.size(), 2);

        map.removeKey(firstKey);

        assertEquals(map.size(), 2);

        map.removeKey(1337);

        assertEquals(map.size(), 2);
    }

    [Test]
    public function testValues():void {
        var collection:Collection = map.values();

        assertTrue(collection.contains(valueNumber));
        assertTrue(collection.contains(valueTestSubject));
        assertTrue(collection.contains(valueString));
        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        collection.remove(secondKey);

        assertTrue(collection.contains(valueNumber));
        assertTrue(collection.contains(valueTestSubject));
        assertTrue(collection.contains(valueString));
        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        collection.remove(valueNumber);

        assertFalse(collection.contains(valueNumber));
        assertTrue(collection.contains(valueTestSubject));
        assertTrue(collection.contains(valueString));
        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        collection.remove(firstKey);

        assertFalse(collection.contains(valueNumber));
        assertTrue(collection.contains(valueTestSubject));
        assertTrue(collection.contains(valueString));
        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        map.removeKey(secondKey);

        assertFalse(collection.contains(valueNumber));
        assertFalse(collection.contains(valueTestSubject));
        assertTrue(collection.contains(valueString));
        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        collection.remove(valueString);

        assertFalse(collection.contains(valueNumber));
        assertFalse(collection.contains(valueTestSubject));
        assertFalse(collection.contains(valueString));
        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertFalse(map.containsKey(thirdKey));

        assertTrue(map.isEmpty());
        assertTrue(collection.isEmpty());

        assertEquals(map.size(), 0);
        assertEquals(collection.size(), 0);
    }

    [Test]
    public function testClear():void {
        assertEquals(map.size(), 3);

        map.clear();

        assertEquals(map.size(), 0);

        map.clear();

        assertEquals(map.size(), 0);
    }

    [Test]
    public function testIsEmpty():void {
        assertFalse(map.isEmpty());

        map.clear();

        assertTrue(map.isEmpty());

        map.clear();

        assertTrue(map.isEmpty());
    }

    [Test]
    public function testKeySet():void {
        var set:Set = map.keySet();

        assertTrue(set.contains(firstKey));
        assertTrue(set.contains(secondKey));
        assertTrue(set.contains(thirdKey));
        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(valueTestSubject);

        assertTrue(set.contains(firstKey));
        assertTrue(set.contains(secondKey));
        assertTrue(set.contains(thirdKey));
        assertTrue(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(firstKey);

        assertFalse(set.contains(firstKey));
        assertTrue(set.contains(secondKey));
        assertTrue(set.contains(thirdKey));
        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(firstKey);

        assertFalse(set.contains(firstKey));
        assertTrue(set.contains(secondKey));
        assertTrue(set.contains(thirdKey));
        assertFalse(map.containsKey(firstKey));
        assertTrue(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        map.removeKey(secondKey);

        assertFalse(set.contains(firstKey));
        assertFalse(set.contains(secondKey));
        assertTrue(set.contains(thirdKey));
        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertTrue(map.containsKey(thirdKey));

        set.remove(thirdKey);

        assertFalse(set.contains(firstKey));
        assertFalse(set.contains(secondKey));
        assertFalse(set.contains(thirdKey));
        assertFalse(map.containsKey(firstKey));
        assertFalse(map.containsKey(secondKey));
        assertFalse(map.containsKey(thirdKey));

        assertTrue(map.isEmpty());
        assertTrue(set.isEmpty());

        assertEquals(map.size(), 0);
        assertEquals(set.size(), 0);
    }

    [Test]
    public function testToString():void {
        var str:String = Object(map).toString();

        assertTrue(str != null);
        assertTrue(str.length > 0);

        trace(str);
    }

    protected function addContent():void {
        firstKey            = new TestSubject("first");
        secondKey           = new TestSubject("second");
        thirdKey            = new TestSubject("third");
        valueNumber         = 1234;
        valueTestSubject    = new TestSubject("value");
        valueString         = "value";

        map.put(firstKey, valueNumber);
        map.put(secondKey, valueTestSubject);
        map.put(thirdKey, valueString);
    }
}

}
