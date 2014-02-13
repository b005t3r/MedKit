/**
 * User: booster
 * Date: 12/02/14
 * Time: 10:58
 */
package medkit.pattern {
import medkit.string.StringBuilder;

public class Pattern {
    private var _map:Vector.<Tile>;
    private var _width:int;
    private var _height:int;

    public function Pattern(width:int, height:int, initialTile:Tile = null) {
        _width  = width;
        _height = height;
        _map    = new Vector.<Tile>(width * height, true);

        if(initialTile == null)
            return;

        var count:int = width * height;
        for(var i:int = 0; i < count; i++)
            _map[i] = initialTile;
    }

    public function get width():int { return _width; }
    public function get height():int { return _height; }

    public function getTile(x:int, y:int):Tile {
        if(x < 0 || y < 0 || x >= _width || y >= _height)
            throw new ArgumentError("x and/or y not in range; x: " + x + ", y: " + y + ", width: " + _width + ", height: " + _height);

        return _map[y * _width + x];
    }

    public function setTile(tile:Tile, x:int, y:int):void {
        if(x < 0 || y < 0 || x >= _width || y >= _height)
            throw new ArgumentError("x and/or y not in range; x: " + x + ", y: " + y + ", width: " + _width + ", height: " + _height);

        _map[y * _width + x] = tile;
    }

    public function toString():String {
        var builder:StringBuilder = new StringBuilder(_width * (_height + 1));

        for(var y:int = 0; y < _height; y++) {
            for(var x:int = 0; x < _width; x++) {
                var tile:Tile = _map[y * _width + x];
                builder.append(tile != null ? String(tile) : " ");
            }

            builder.append("\n");
        }

        return builder.toString();
    }
}
}
