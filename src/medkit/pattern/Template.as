/**
 * User: booster
 * Date: 12/02/14
 * Time: 11:17
 */
package medkit.pattern {
import flash.errors.IllegalOperationError;

public class Template {
    private var _matchingPattern:Pattern;
    private var _notMatchingPattern:Pattern;
    private var _outputPattern:Pattern;

    private var _xOffset:int;
    private var _yOffset:int;

    public function Template(matching:Pattern, notMatching:Pattern = null, output:Pattern = null, xOffset:int = 0, yOffset:int = 0) {
        _matchingPattern    = matching;
        _notMatchingPattern = notMatching;
        _outputPattern      = output;
        _xOffset            = xOffset;
        _yOffset            = yOffset;
    }

    public function findMatches(pattern:Pattern, resultMatches:Vector.<Match> = null):Vector.<Match> {
        if(resultMatches == null)
            resultMatches = new <Match>[];

        for(var x:int = 0; x < pattern.width - _matchingPattern.width + 1; x++) {
            for(var y:int = 0; y < pattern.height - _matchingPattern.height + 1; y++) {
                if(matchesAt(pattern, x, y))
                    resultMatches[resultMatches.length] = new Match(x, y);


            }
        }

        return resultMatches;
    }

    public function matchesAt(pattern:Pattern, x:int, y:int):Boolean {
        for(var ix:int = 0; ix < _matchingPattern.width; ix++) {
            for(var iy:int = 0; iy < _matchingPattern.height; iy++) {
                var patternTile:Tile = pattern.getTile(x + ix, y + iy);
                var matchingTile:Tile = _matchingPattern.getTile(ix, iy);

                if(! TileUtil.matches(patternTile, matchingTile))
                    return false;

                var notMatchingTile:Tile = _notMatchingPattern != null ? _notMatchingPattern.getTile(ix, iy) : null;

                if(notMatchingTile != null && TileUtil.matches(patternTile, notMatchingTile))
                    return false;
            }
        }

        return true;
    }

    public function applyMatches(pattern:Pattern, matches:Vector.<Match>):void {
        var matchesCount:int = matches.length;
        for(var i:int = 0; i < matchesCount; i++) {
            var match:Match = matches[i];

            applyAt(pattern, match.x, match.y);
        }
    }

    public function applyAt(pattern:Pattern, x:int, y:int):void {
        if(_outputPattern == null)
            throw new IllegalOperationError("can't call applyAt() when an output pattern is not set");

        for(var ix:int = 0; ix < _outputPattern.width; ix++) {
            for(var iy:int = 0; iy < _outputPattern.height; iy++) {
                var tile:Tile = _outputPattern.getTile(ix, iy);

                if(tile == null)
                    continue;

                pattern.setTile(tile, x + ix + _xOffset, y + iy + _yOffset);
            }
        }
    }
}
}
