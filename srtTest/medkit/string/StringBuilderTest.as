/**
 * User: booster
 * Date: 11/18/12
 * Time: 15:32
 */
package medkit.string {
import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertTrue;

public class StringBuilderTest {
    public static const CAPACITY:int = 40;

    private var builder:StringBuilder;

    [Before]
    public function setUp():void {
        builder = new StringBuilder(CAPACITY);
    }

    [After]
    public function tearDown():void {
        builder = null;
    }

    [Test]
    public function testAppend():void {
        builder.append("a");

        assertEquals(builder.toString(), "a");

        builder.append("b").append("c");

        assertEquals(builder.toString(), "abc");

        builder.append(1);

        assertEquals(builder.toString(), "abc1");

        builder.append(1.23);

        assertEquals(builder.toString(), "abc11.23");

        builder.append(builder);

        assertEquals(builder.toString(), "abc11.23" + "abc11.23");
    }

    [Test]
    public function testLength():void {
        assertEquals(builder.length(), 0);

        builder.append("1").append("2").append("3");

        assertEquals(builder.length(), 3);

        builder.append(builder);

        assertEquals(builder.length(), 6);
    }

    [Test]
    public function testTrimToSize():void {
        builder.append("12345");

        assertEquals(builder.toString(), "12345");
        assertEquals(builder.length(), 5);

        builder.trimToSize();

        assertEquals(builder.toString(), "12345");
        assertEquals(builder.length(), 5);

        builder.append("6");

        assertEquals(builder.toString(), "123456");
        assertEquals(builder.length(), 6);

        builder.trimToSize();

        assertEquals(builder.toString(), "123456");
        assertEquals(builder.length(), 6);
    }

    [Test]
    public function testToString():void {
        assertEquals(builder.toString(), "");

        var string:String = "This is a string. ";

        builder.append(string).append(string);

        assertEquals(builder.toString(), string + string);
    }

    [Test]
    public function testEnsureCapacity():void {
        builder.append("12345");

        assertEquals(builder.toString(), "12345");
        assertEquals(builder.length(), 5);

        builder.ensureCapacity(3 * CAPACITY);

        assertEquals(builder.toString(), "12345");
        assertEquals(builder.length(), 5);

        builder.append("6");

        assertEquals(builder.toString(), "123456");
        assertEquals(builder.length(), 6);

        builder.ensureCapacity(CAPACITY / 2);

        assertEquals(builder.toString(), "123456");
        assertEquals(builder.length(), 6);
    }

    [Test]
    public function testSetLength():void {
        builder.append("123456789");

        builder.setLength(5);

        assertEquals(builder.toString(), "12345");

        builder.setLength(10);

        assertEquals(builder.toString(), "12345");

        builder.append("6789");

        assertEquals(builder.toString(), "123456789");
    }

    [Test]
    public function testCapacity():void {
        assertEquals(builder.capacity(), CAPACITY);

        builder.ensureCapacity(CAPACITY * 2);

        assertTrue(builder.capacity() >= CAPACITY * 2);

        builder.ensureCapacity(CAPACITY * 3);

        assertTrue(builder.capacity() >= CAPACITY * 3);
    }

    [Test]
    public function testCharCodeAt():void {
        builder.append("123456789");

        assertEquals(builder.charCodeAt(2), "3".charCodeAt());
    }
}
}
