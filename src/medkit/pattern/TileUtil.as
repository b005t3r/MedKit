/**
 * User: booster
 * Date: 13/02/14
 * Time: 14:43
 */
package medkit.pattern {
public class TileUtil {
    public static function matches(tileA:Tile, tileB:Tile):Boolean {
        if(tileA == null || tileB == null)
            return true;

        return tileA.equals(tileB);
    }
}
}
