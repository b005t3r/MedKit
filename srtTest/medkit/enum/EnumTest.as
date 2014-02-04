/**
 * User: booster
 * Date: 2/10/13
 * Time: 10:28
 */

package medkit.enum {

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class EnumTest {
    [Test]
    public function testEnums():void {
        var wednesday:DayOfWeek = DayOfWeek.Wednesday;

        assertEquals(wednesday, DayOfWeek.Wednesday);
        assertFalse(wednesday == DayOfWeek.Tuesday);

        var allValues:Array = Enum.allEnums(DayOfWeek);

        assertEquals(allValues.length, 7);
        assertEquals(allValues[0], DayOfWeek.Monday);
        assertEquals(allValues[1], DayOfWeek.Tuesday);
        assertEquals(allValues[2], DayOfWeek.Wednesday);
        assertEquals(allValues[3], DayOfWeek.Thursday);
        assertEquals(allValues[4], DayOfWeek.Friday);
        assertEquals(allValues[5], DayOfWeek.Saturday);
        assertEquals(allValues[6], DayOfWeek.Sunday);

        assertTrue(wednesday.index() > DayOfWeek.Monday.index());
        assertTrue(wednesday.index() > DayOfWeek.Tuesday.index());
        assertTrue(wednesday.index() == DayOfWeek.Wednesday.index());
        assertTrue(wednesday.index() < DayOfWeek.Thursday.index());
        assertTrue(wednesday.index() < DayOfWeek.Friday.index());
        assertTrue(wednesday.index() < DayOfWeek.Saturday.index());
        assertTrue(wednesday.index() < DayOfWeek.Sunday.index());

        assertEquals(0, DayOfWeek.Monday.index());
        assertEquals(1, DayOfWeek.Tuesday.index());
        assertEquals(2, DayOfWeek.Wednesday.index());
        assertEquals(3, DayOfWeek.Thursday.index());
        assertEquals(4, DayOfWeek.Friday.index());
        assertEquals(5, DayOfWeek.Saturday.index());
        assertEquals(6, DayOfWeek.Sunday.index());
    }
}

}

import medkit.enum.Enum;

[Order("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")]
class DayOfWeek extends Enum {
    // static constructor
    { initEnums(DayOfWeek); }

    public static const Monday:DayOfWeek = new DayOfWeek();
    public static const Tuesday:DayOfWeek = new DayOfWeek();
    public static const Wednesday:DayOfWeek = new DayOfWeek();
    public static const Thursday:DayOfWeek = new DayOfWeek();
    public static const Friday:DayOfWeek = new DayOfWeek();
    public static const Saturday:DayOfWeek = new DayOfWeek();
    public static const Sunday:DayOfWeek = new DayOfWeek();
}
