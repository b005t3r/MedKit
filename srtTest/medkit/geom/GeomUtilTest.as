/**
 * User: booster
 * Date: 08/05/14
 * Time: 10:34
 */
package medkit.geom {
import flash.geom.Rectangle;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertTrue;

public class GeomUtilTest {
    public function GeomUtilTest() {
    }

    /**
     *     +--+
     *     | B|
     * +---|--|
     * |   +--+
     * |A     |
     * |      |
     * +--+---+
     * |  |
     * |C |
     * +--+
     */
    [Test]
    public function testRectangleSubtraction():void {
        var rectA:Rectangle = new Rectangle(0, 2, 4, 3);
        var rectB:Rectangle = new Rectangle(2, 0, 2, 3);
        var rectC:Rectangle = new Rectangle(0, 5, 2, 3);

        var result:Vector.<Rectangle>;

        result = GeomUtil.rectangleSubtraction(rectA, rectB);

        assertEquals(3, result.length);
        assertTrue(containsRect(result, new Rectangle(0, 2, 2, 1)));
        assertTrue(containsRect(result, new Rectangle(0, 3, 2, 2)));
        assertTrue(containsRect(result, new Rectangle(2, 3, 2, 2)));

        result = GeomUtil.rectangleSubtraction(rectB, rectA);

        assertEquals(1, result.length);
        assertTrue(containsRect(result, new Rectangle(2, 0, 2, 2)));

        result = GeomUtil.rectangleSubtraction(rectB, rectC);

        assertEquals(1, result.length);
        assertTrue(containsRect(result, rectB));

        result = GeomUtil.rectangleSubtraction(rectC, rectB);

        assertEquals(1, result.length);
        assertTrue(containsRect(result, rectC));

        result = GeomUtil.rectangleSubtraction(rectA, rectC);

        assertEquals(1, result.length);
        assertTrue(containsRect(result, rectA));

        result = GeomUtil.rectangleSubtraction(rectC, rectA);

        assertEquals(1, result.length);
        assertTrue(containsRect(result, rectC));

        result = GeomUtil.rectangleSubtraction(rectA, rectA);

        assertEquals(0, result.length);
    }

    private function containsRect(vector:Vector.<Rectangle>, rect:Rectangle):Boolean {
        var count:int = vector.length;
        for(var i:int = 0; i < count; i++) {
            var rectangle:Rectangle = vector[i];

            if(rect.x == rectangle.x && rect.y == rectangle.y
            && rect.width == rectangle.width && rect.height == rectangle.height)
                return true;
        }

        return false;
    }
}
}
